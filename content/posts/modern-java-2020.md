+++
date = "2020-05-07"
title = "Modern Java Tips/Tricks"
author = "{{ .Site.Author.name }}"
description = "Modern Java Tips/Tricks"
draft = true
+++

Java development comes under a lot of heat these days, and rightfully so, in some cases.
Working for a Software Consultancy for the last 4 years has given me exposure to a lot of
"legacy" Java stacks attempting to solve modern problems. And let's be fair - some of them
kind of work. But I also get to work on a lot of what I like to call "modern, lighter Java".
I've also had to convince dev teams that this more modern take is worth the switch. Here are
some excerpts from those discussions that I find myself revisiting. Maybe they can be helpful
to your own push!

## Lombok Your Life

This one is so big to me I had to include it first. The one thing I say I cannot live without
in Java projects is [Lombok](https://projectlombok.org/). I push quite hard on greenfield teams
to include Lombok in the mix. I also look for any reason to introduce it slowly to legacy code
projects as well. It's not an all-or-nothing! You can slowly introduce it.

If you've never seen Lombok before: it's a boilerplace reduction tool. It allows you to take
code like this:

```java

public class User {
  private final String firstName;
  private final String lastName;
  private final String email;

  public User(String firstName, String lastName, String email) {
    //...
  }

  // all the getters and setters

  @Override
  public String toString() { ... }

  // You do remember how to properly make one of these, right? ....because I don't
  public int hashCode() { ... }
}
```

And instead write this:

```java
import lombok.Data

@Data
public class User {
  private final String firstName;
  private final String lastName;
  private final String email;
}
```

Imagine those massive models you use to represent your JSON input/output models.

Using Spring Boot? Or any library supporting constructor-based dependency injection?
Stop worrying about your service's constructor growing:

```java
@AllArgsConstructor
public class UserValidationService {
  private UserRepository repository;
  private UserRoleValidator roleValidator;
  private ThirdPartyLoginClient loginClient;

  // Insert your million dollar business logic here!
}
```

And this is just scraping the surface of what all Lombok does. Most modern IDEs support Lombok
annotations (even Vim supports it. Think about that). It's a huge time saver, quality of life
improvement, and eases the pain of not being in Scala to begin with! (...slightly)

## Upgrade Your JDK

_Seriously_. I know there are _some_ companies that are truly stuck on older JVMs for various
reasons. But there are ways to fix that. And even just getting up to Java 8, if you aren't
already, unlocks a host of quality-of-life improvements. Streams? Optionals? Better garbage
collection? _Lombok_??

If you can jump to Java 11, even better! Once Java 14, Records, and Switch Expressions become
GA? Oh I need Records and Switch Expressions in my life....when I'm stuck in Java.

## Get off the Standalone Servlet Container

Do you run a standalone Tomcat/Websphere/Jetty? Do you throw your WAR/EAR over to a team
who is dedicated to copying the same folder structure to new servers, copying config files
you aren't allowed to touch (even though you have those credentials to the Prod DB. You
know you do!), and "tuning the container for multi-app environments"?

Give self-contained (i.e fat) JARs a try. Mind you, this does require a framework that embeds the
container within your app or runs on a modern server stack. Spring Boot, Dropwizard, Play,
all have that capability. It's very rare that I run into a company that isn't running one of
these stacks (or one of their older derivatives).

And I'm not even pushing for Docker here! Even just simplifying your deployment to a standalone
JAR has a much nicer development experience. Local development, especially. It just happens
to be nicer to migrate a self-contained JAR to a containerized environment later.

And push that configuration to environment variables, while you are at it.

I wish we could make this one a requirement of anyone migrating to a Cloud environment.

## Upgrade Your Build Tool

Maven and Gradle have come a _long_ way. There are newer, flashier build tools out there, as well,
but I've found Maven and Gradle to be great bang for the buck. They're well supported, well
documented (Googlability metric for the win!), they [both](https://github.com/takari/maven-wrapper) [have](https://docs.gradle.org/current/userguide/gradle_wrapper.html) wrappers that allow
someone new to checkout the code and build immediately (you did get off that standalone Servlet
container, right?), and they have a lot of tooling built around them. Seriously, just look at the
[Gradle Plugins Page](https://plugins.gradle.org/).

## Upgrade Your Dependencies

This one is a real kicker because it can sometimes kick you back...hard. I'm not actually
advocating to be on the bleeding edge. I've done that enough. I am, indeed, still bloody (
but happy!). What I'm mostly picking at is enabling the ability to upgrade. I see _a lot_ of
people using Postgres but sticking to pre-version 9. I still see Spring Boot 1.4 and lower in
Production (we're in 2.0 now). Upgrade your dependencies. Even if you can't do a major version
change yet for some reason, stay on top of those minor versions. Most big libraries keep to
the SemVer rules of "don't break APIs in minor versions".

## Error Handling != Exceptions

This one is laced with opinion, I admit. But it's also been drilled into me with Functional
Programming and it genuinely has changed my Java career. Stop throwing exceptions as a form
of normal error handling. Throw exceptions for _exceptional cases_.

This may add more models to your stack, and that's OK (you using Lombok yet?). Proper error
modeling forces you to really understand both the happy and error paths of your code. It also
makes it _very_ explicit what errors you expect. In my experience this has cleaned up code,
reduced the amount of context I have to keep in my head when reading code, and has come with
a much nicer Production Support experience.

And I have to call this one out. _Stop throwing RuntimeExceptions for normal errors_. Stop it. _Stop it_.
If you are throwing RuntimeException because you don't want to add **throws** to all your
methods, you've probably not handled that error properly!

## Conclusion

Java is often criticized for being a boring, verbose, esoteric language that's falling behind more
modern equivalents. But with a few changes to your process, your tool chain, or your paradigm,
it can actually be a _decent experience_.

Hope this helps! Thanks for stopping by the Lab!
