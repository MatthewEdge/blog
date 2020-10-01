+++
date = "2020-09-30"
title = "Lab Log: Building a Twitch Bot in Go - Day 2"
author = "Matthew Edge"
description = ""
tags = ["golang", "irc", "twitch", "chatbot"]
draft = true
+++

Welcome back to the Lab Log! Where we last left off - the code was
connecting to, and reading from, our own chat! We had the foundations
for the Bot in place, so now we just needed to start parsing chat and
getting some commands going! Easy, right?....

## Auth Problems Abound

Authentication always seems to be a sticking point for projects, and
this humble little Go Bot was no exception. We struggled for a good
while trying to figure out why we suddenly got disconnected from the
IRC with the token I generated before stream. It was frustrating, but
a fun opportunity to show what happens when things go wrong!

And, as luck would have it, it was due to an environment variable not
being sourced properly. Oh the little things that can bring an application
to the floor...

## Functions, Structs, And Abstractions

After we got past Auth, the first Stream Goal was removing duplicate code
that was handling reading from, and writing to, the Websocket connection.
We started by simply extracting this code to functions, showing how we
can quickly clean the code up by creating small, single-purpose functions
to perform these actions.

Shortly after that, though, I decided to introduce structs and methods.
While functions were a great first step, Go's struct concept is a powerful
mechanism for creating abstractions over lower-level implementations. In
our case, we created a wrapping struct around Gorilla's own websocket.Conn
that attempted to hide the details of what we used to connect to, and interact
with, the IRC. I'm a fan of keeping things simple, and only adding abstractions
when you know you need them, but this seemed like a great place to abstract
the low-level socket communication pieces.

We also had a great discussion about named outputs, a concept in Go that
allows you to do something like this:

```
func (irc *Irc) Read() (msg string, err error) {
  // do something and assign results to msg and err
  return
}
```

Note the named output variables `msg` and `err`. While this can be a handy
short-hand, I'm not, personally, a fan of this style. Mutating variables
anywhere in the function block and, confusingly, exiting with just a
`return` was a bit much for my C/Scala brain to grasp. It seemed like
chat agreed! We opted, instead, for the more traditional, explicit syntax:

```
func (irc *Irc) Read() (string, error) {
  // do something and assign results to msg and err
  return msgStr, nil // for a success
}

```

## Medgelabs Philosophy

Make it work, Make it right, Make it pretty. In that order...preferably!
This is something of a recurring phrase in my career...though I fail to
recall where it originally came from. My goal when writing code is to get
a working solution, as clean as possible, but likely in need of improvement.
Then, I'll work on iterating over a cleaner, more readable solution, if
necessary, including expanding any tests I may have written during the first
pass, or improving on the interface I may have built.

I don't believe in perfect code. I believe in code that works as well as it can,
based on what we know today. We don't know what tomorrow looks like, but we
do the best we can!

## Ping/Pong

After dealing with a rather fun "feature" of duplicate chat lines, the first thing
we wanted to do was implement the requisite PING/PONG check. This is a message
that Twitch sends to ensure clients are active. If we don't respond to Twitch's
`PING` message with the expected `PONG`, we get YEET'd out of the IRC. This was
also our first stab at parsing IRC lines into something we could actually process.
The simple `strings.HasPrefix()` method got us going.

## Conclusion

Doesn't seem like a lot, but these small steps are helping to set the foundation for
the next steps in out Bot building journey! Getting a core requirement built allows
us to focus on the next step: parsing chat to respond to commands!

Thanks for stopping by The Lab!
