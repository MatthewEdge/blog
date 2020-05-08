+++
date = "2020-05-27"
title = "Functional Programming and a Goban"
author = "Matthew Edge"
description = "http4s, fs2, and building a Go board game"
tags = ["scala", "http4s", "functional-programming"]
draft = true
+++

When it comes to building purely functional web APIs in Scala, you may have heard the name **http4s** come up.
http4s is a purely functional web application library that utilizes the Cats library and exposes APIs for you
to use to build your apps. It's a fantastic library and definitely worth a look.

## How DO I actually start??

The homepage for http4s has a decent tutorial on the basic concepts and how they are used. You'll learn about
Services, the routing DSL, and how to start a Blaze server (their underlying server tech, much like Netty, etc).
By the end of the tutorial you might have something like this:

```scala
import cats.effect.{ExitCode, IO, IOApp}
import cats.implicits._
import org.http4s._
import org.http4s.implicits._
import org.http4s.dsl.io._
import org.http4s.server.middleware.Logger
import org.http4s.server.blaze.BlazeServerBuilder
import org.http4s.HttpRoutes

object Main extends IOApp {
  def run(args: List[String]) = {
    val service = HttpRoutes.of[IO] {
        case GET -> Root / "hello" / name => Ok(s"Hello $name")
      }
      .orNotFound

    val withLogger = Logger.httpApp(true, true)(service)

    BlazeServerBuilder[IO]
      .bindHttp(8080, "0.0.0.0")
      .withHttpApp(withLogger)
      .serve
      .compile
      .drain
      .as(ExitCode.Success)
  }
}
```

The TL;DR is `service` shows off the routing DSL. Any HTTP GET requests to `/hello/:name` will return a HTTP 200 with a greeting
to the given name. The `.orNotFound` part ensures a HTTP 404 is returned for any other requests we receive. Next, the
`withLogger` piece demonstrates http4s middleware by creating a request logger around out services, logging headers and the body.
Finally, the `BlazeServerBuilder` chain creates a HTTP Server using the Stream API that will run until the application is killed
externally (that's what all the `.compile.drain.as` stuff is doing).

## Pt 2

Alternatively, you might have found the http4s giter8 template and seen you can run `sbt new http4s/http4s.g8`. And then you're
presented with this (note that this is condensed for blog purposes):

In a Routes.scala file:

```scala
import cats.effect.Sync
import cats.implicits._
import org.http4s.HttpRoutes
import org.http4s.dsl.Http4sDsl

object Routes {

  def jokeRoute[F[_]: Sync]: HttpRoutes[F] = {
    val dsl = new Http4sDsl[F]{}
    import dsl._
    HttpRoutes.of[F] {
      case GET -> Root / "joke" => Ok("Really bad dad joke here")
    }
  }

  def helloRoute[F[_]: Sync]: HttpRoutes[F] = {
    val dsl = new Http4sDsl[F]{}
    import dsl._
    HttpRoutes.of[F] {
      case GET -> Root / "hello" => Ok("Hi!")
    }
  }
}
```

And in a condensed Main file:

```scala
import cats.effect.{ConcurrentEffect, ContextShift, ExitCode, IO, IOApp, Timer}
import cats.implicits._
import fs2.Stream
import org.http4s.client.blaze.BlazeClientBuilder
import org.http4s.implicits._
import org.http4s.server.blaze.BlazeServerBuilder
import org.http4s.server.middleware.Logger
import org.http4s.dsl.io._
import scala.concurrent.ExecutionContext.global

object Main extends IOApp {

  def run(args: List[String]) = stream[IO].compile.drain.as(ExitCode.Success)

  def stream[F[_]: ConcurrentEffect](implicit T: Timer[F], C: ContextShift[F]): Stream[F, Nothing] = {
    for {
      client <- BlazeClientBuilder[F](global).stream

      httpApp = (
        Routes.jokeRoute[F] <+>
        Routes.helloRoute[F]
      ).orNotFound

      // With Middlewares in place
      finalHttpApp = Logger.httpApp(true, true)(httpApp)

      exitCode <- BlazeServerBuilder[F]
        .bindHttp(8080, "0.0.0.0")
        .withHttpApp(finalHttpApp)
        .serve
    } yield exitCode
  }.drain
}
```

_uh_...what?

There's a lot going on here, especially if you haven't been riding the Functional Programming train the last couple years.

## From The Top

Let's start with the service we started with:

```scala
val service = HttpRoutes.of[IO] {
  case GET -> Root / "hello" / name => Ok(s"Hello $name")
}
```

```scala
object Routes {

  def jokeRoute[F[_]: Sync]: HttpRoutes[F] = {
    val dsl = new Http4sDsl[F]{}
    import dsl._
    HttpRoutes.of[F] {
      case GET -> Root / "joke" => Ok("Really bad dad joke here")
    }
  }

  def helloRoute[F[_]: Sync]: HttpRoutes[F] = {
    val dsl = new Http4sDsl[F]{}
    import dsl._
    HttpRoutes.of[F] {
      case GET -> Root / "hello" => Ok("Hi!")
    }
  }
}
```

The services are still showing the routing DSL, but now we have that strange type parameter `F[_]: Sync`. They also have that wierd
`dsl` object which we're importing....something from. The rest looks like what we had before.

The `F[_]` type is known as _tagless final_.
