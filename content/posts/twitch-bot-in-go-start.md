+++
date = "2020-09-29"
title = "Lab Log: Building a Twitch Bot in Go - Day 1"
author = "Matthew Edge"
description = ""
tags = ["golang", "irc", "twitch", "chatbot"]
+++

One month ago I started streaming on Twitch! There were a number of reasons for deciding
to start coding live, but ultimately I wanted to show that software development,
in the real world, is not about knowing answers up front. It's about finding those answers
and coming up with applicable solutions, however you may find that information! There are,
rarely, right answers! :) It's meant to be a peek into what my day to day as a Software
Developer looks like and, ideally, we learn things along the way!

Recently, it was recommended by one of my lovely viewers, `dal3xx`, that I write
an accompanying blog post for the streams to go over, in more detail, what went on and
why I chose to do things the way I did. And so, I present the Lab Log! Thanks Dal!

## Twitch Bot using IRC Chat

First things first: what are we actually doing? For our first project on Twitch, I
decided to take a stab at writing a Chat Bot for Twitch. Being a moderator for two
other amazing streamers (our wonderful mod: [@SorceryAndSarcasm](https://twitch.tv/sorceryandsarcasm)
, and the amazing [@SpookyGhostMachine](https://twitch.tv/spookyghostmachine)) finds me using chat
bots like Nightbot and Streamlabs quite a lot. Digging around the [Twitch Developer Documentation](https://dev.twitch.tv/docs/irc/guide)
led me to discover that Twitch Chat is actually an IRC client!

IRC has been around for a _long time_. The interface is well defined and there are a
ton of connectivity options implemented in a number of languages. To implement a Bot,
at a high level, I would need:

* A persistent connection to the IRC Server. Websockets seemed like a great option for this!
* Credentials! Still working this one out, to this day. We use test credentials on stream
* Ability to parse IRC messages
* Ability to send messages to IRC chat (PRIVMSG command, in IRC terms)

This formed the basis for the work for the first stream!

## Why Golang?

Honestly, because Go has become one of my favorite programming languages! I love its
simplicity, I adore how powerful the tooling is, and the ease of deployment (native
binaries. _Amazing_) really sings to me. Additionally, I am a bit of a Concurrency and
Distributed Computing nut. I love that stuff. Finally, my history in C and Scala made the
language feel quite familiar.

## Getting Started

It is, of course, customary to start with a Hello World! The universe gets out of balance
if you dont! For me: this was setting up a Go Modules project (which I prefer over the
GOPATH approach), a Makefile for common commands, and writing a quick `main.go` to print
to the console.

Next, it was back to the Dev Docs! I was looking for any hints on how to
connect, what networking protocols it supported, if they had their own SDK or client,
and any authentication requirements. Right at the top of the Docs was information on
how to connect via a Websocket connection! Given I have plenty of history with Websockets,
my eyes trained in on this option. I also saw my first glimpse at how the use of IRC
commands (PASS and NICK) looked. This gave me some context to consider when looking for
Websocket client libraries!

It was during this time that we got our first raid, as well! Big shout out to [@ShredderPlays](https://www.twitch.tv/ShrederPlays)
and the raiders for stopping in!

After looking through the client [included with the Go standard library](https://godoc.org/golang.org/x/net/websocket),
the [nhooyr client](https://godoc.org/nhooyr.io/websocket), and the [Gorilla Websocket client](https://godoc.org/github.com/gorilla/websocket),
I decided to go with the Gorilla client. Their documentation was fantastic, they are a
well known library in the Go community, and they even included examples! Just goes to show:
your documentation and inclusion of examples can make a big difference to the adoption of
your Open Source library!

## Connecting to the IRC

After adding the Gorilla Websocket library to the project with a quick `go get -u`, we were
ready to connect. We spent a good deal of time looking through Gorilla's documentation
and adding the various pieces to our code. We also took some time to talk about handling
errors, one of my favorite Go features: defer, and how to use these constructs throughout
our code! When you first connect to the IRC you're greeted with a blank console... and
questions about whether you did it right or not! This turned out to be where we needed
to use the aforementioned `PASS` and `NICK` IRC commands. We also introduced the idea
of pulling secrets from environment variables instead of copying them into the code,
and why plaintext secrets are a bad idea! After a bit of debugging, a couple tries,
and a quick prayer to the Code Gods - success!

```
< PASS oauth:<Twitch OAuth token>
< NICK <user>
> :tmi.twitch.tv 001 <user> :Welcome, GLHF!
> :tmi.twitch.tv 002 <user> :Your host is tmi.twitch.tv
> :tmi.twitch.tv 003 <user> :This server is rather new
> :tmi.twitch.tv 004 <user> :-
> :tmi.twitch.tv 375 <user> :-
> :tmi.twitch.tv 372 <user> :You are in a maze of twisty passages.
> :tmi.twitch.tv 376 <user> :>
```

Seeing this message means we're in!

## Conclusion

Is it a Bot yet? Not technically, but it's still so elating to see even the small successes
when working on projects like this! And it was so much fun having chat along for the ride!
We had some great conversations, I learned a thing or two based on suggestions from viewers,
and, hopefully, chat enjoyed the time as well!

Next time: getting chat to start showing up on the console!

Thanks for stopping by The Lab!
