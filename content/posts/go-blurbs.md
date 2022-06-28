+++
date = "2021-01-04"
title = "Golang - Lessons Learned"
author = "Matthew Edge"
description = "Various things learned from my time with Go"
draft = true
+++

## Checking for Type Adherence

You can check if a struct implements an interface using a discarded variable and the `new()` built-in:

```go
type Thing interface {
  Fn() int
  Bn() int
}

// PartialThing only implements Fn() and, thus, is not a valid Thing
type PartialThing struct {}

func (p *PartialThing) Fn() int {
  return 1
}

// Using this trick: we can get the compiler to tell us if PartialThing implements Thing. In this case it does not
var _ Thing = new(PartialThing)
```

The last line will result in a compilation error like the following:

```

```

Many OSS libraries used this technique (though a slightly different form: `var _ Thing = (*PartialThing)(nil)`) to check
type enforcement at compile-time more quickly than requiring a method arg to check.

## encoding/json Oddities

`integers are unmarshalled to float64 when the dest argument is an interface{}`

Encountered this oddity when decoding JSON to a raw `map[string]interface{}` and surprised to see the type resolve
as a float64 (at the time of this writing: June 2022 on Go 1.18).

## Decoder and file.Seek(0, io.SeekStart)

If decoding from a local `os.File` it  may be necessary to call `file.Seek(0, io.SeekStart)` to ensure you're
reading from the start of the file for consumption.
For example: if you're encoding many entries to a `os.File` that's kept open (such as for a local disk cache)
and then, later, reading them all back from the same `os.File` then executing an explicit `file.Seek(0, io.SeekStart)`
ensures you don't start reading from a random place in the file.

NOTE: If this is meant to be wrapped in thread-safe code then guard with a Mutex.

## sync.WaitGroup Initialization

Make sure `wg.Add(..)` is performed _outside_ of the consuming goroutine that is calling `wg.Done()`. You have no
guarantees that all `wg.Add(..)` calls complete before the first `wg.Done()`. i.e don't do this:

```go
var wg sync.WaitGroup

for i := 0; i < count; i++ {
  go func(id int) {
    wg.Add(1) // WRONG PLACEMENT!
    // ... process record
    wg.Done()
  }(i)
}
// If all goroutines didn't get wg.Add(1) in then this will only wait
// for those that got added in time
wg.Wait()
```

`wg.Add(1)` should be in the for loop, just above the goroutine call:

```go
var wg sync.WaitGroup
for i := 0; i < count; i++ {
  wg.Add(1)

  go func(id int) {
    // ... process record
    wg.Done()
  }(i)
}
wg.Wait()

```

## Synchronizing goroutines? Always pass sync.Mutex by Reference

sync.Mutex is a struct (and, thus, a value type). Passing a Mutex to a function for shared usage without the dereference
operator (`&`) means Go will _make a copy_ of the Mutex and, thus, no synchronization will occur as all copies are their
own locks.

i.e don't do this:

```go
func main() {
    var mu sync.Mutex{}

    go Process(mu) // this is a copy of mu, not the original!
    go Process(mu) // Neither of these calls are now synced!
}
```

Instead, pass by reference:

```go
func main() {
    var mu sync.Mutex{}

    go Process(&mu) // the & sign is subtle but important!
    go Process(&mu)
}
```

Note: _structs_ are value types. When passed to functions: structs are copied (not referenced). This means that
Mutexes embedded in structs (field or struct embedding) are just as succeptable if you don't pass the struct itself
by reference.
