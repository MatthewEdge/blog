+++
date = "2020-05-07"
title = "Modern Java Tips/Tricks"
author = "Matthew Edge"
description = "Modern Java Tips/Tricks"
+++

Java development comes under a lot of heat these days for being verbose, bloated, and terrible for
modern web applications. Rightfully so, in some cases. I've seen a lot of "legacy" Java stacks
in the wild that embody a lot of these criticisms. I've also had the chance to upscale some of
these projects using modern tooling and libraries that actually make the experience much more
enjoyable! Without a lot of the heft, of course.

## Lombok Your Life

This one is so big to me I had to include it first. The one thing I say I cannot live without
in Java projects is [Lombok](https://projectlombok.org/). I push quite hard on greenfield teams
to include Lombok in the mix. I also look for any reason to introduce it slowly to legacy code
projects as well. It's not an all-or-nothing! You can slowly migrate code over to the Lombok style.

If you've never seen Lombok before: it's a boilerplate reduction library. It allows you to take
code like this:

```java

public class User {
  private final String firstName;
  private final String lastName;
  private final String email;

  public User(String firstName, String lastName, String email) {
    //...
  }

  // all the getters and setters omitted for sanity

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
You don't have to rely on an IDE to generate getters/setters, you don't have to
fiddle with them when your model expands / shrinks, you get a nice toString() that
updates automatically when you change fields. It's incredibly convenient!

Using Spring Boot? Or any library supporting constructor-based dependency injection?
Stop worrying about your service's constructor growing:

```java
@AllArgsConstructor
@Service
public class UserValidationService {
  private UserRepository repository;
  private UserRoleValidator roleValidator;
  private ThirdPartyLoginClient loginClient;

  // Insert your million dollar business logic here!
}
```

Using SLF4J as the logging API? Just add `@Slf4j` to your class annotations.

And this is just scraping the surface of what all Lombok does. Most modern IDEs support Lombok
annotations (even Vim supports it. Think about that). It's a huge time saver, quality of life
improvement, and eases the pain of not being in Scala to begin with! (...slightly)

## Use SLF4J APIs

This one seems small, but it's surprising how many teams have locked themselves into log4j, java.logging,
etc because they scattered those imports across their code. Log Library swaps become _heresy_ in these
teams which makes discussions about log centralization a bit more painful than they need to be, in some cases.

Standardize your team on importing the SLF4J APIs instead of the logger's specific APIs. SLF4J is _the_ standard
interface for Java projects. I've, personally, never seen a case where SLF4J didn't cut it, even on applications
with insane logging requirements. Big logging libraries like Logback, Log4j, etc all implement the slf4j-api. Want
to swap logging frameworks? Change the dependency and change your logging config. _That's it_. No code change required!

Are you using Lombok yet? The `@Slf4j` annotation is too easy to add to classes that need logging!

## Centralize Configuration

Ok, this is a bit opinionated, but it also has roots in test ergonomics! I prefer collecting external configurations to
a set of Config objects. It can be one model if it's a small set of config, or it can be specialized models. Either way,
if I'm collecting configuration from the outside world, I collect it in Config objects and pass around / inject those models.

This gives me a couple benefits:

* You have one place to look for configuration required.
* You can change how you retrieve configuration in a much smaller surface area
* You can use that fancy Spring annotation for live but just construct a dumb object for your tests
* _It's not scattered all over your code_

## Use Constructor Injection

If you use dependency injection in your application, say with Spring Boot, inject your dependencies in a Constructor.
You won't have to spin up an entire test stack dedicated to wiring dependencies for you just to write a unit test, and
any time those dependencies change the compiler will warn you about it!

To visualize, don't do this:

```java
public class Service {
  @Autowired Repository repository;
}
```

Instead, do this:

```java
public class Service {
  private Repository repository;

  public Service(Repository repository) {
    this.repository = repository;
  }
}
```

And if you have Lombok (you do, right?):

```java
@AllArgsConstructor
public class Service {
  private Repository repository;
}
```


## Get off the Standalone Servlet Container

Do you run a standalone Tomcat/Websphere/Jetty? Do you throw your WAR/EAR over to a team
who is dedicated to copying the same folder structure to new servers, copying config files
you aren't allowed to touch (even though you have those credentials to the Prod DB. You
know you do!), and "tuning the container for multi-app environments"?

Give self-contained (i.e fat) JARs a try. Mind you, this does require a framework that embeds the
container within your app or runs on a modern server stack. Spring Boot, Dropwizard, Play, and
more, all have that capability. It's very rare that I run into a company that isn't running one of
these stacks (or one of their older derivatives) that couldn't swap. Some are even shimming
new versions of that library back down to Servlet containers!

This is a painful experience. Local development requires a new dependency to be installed just
to run the code, deployment requires additional install and configuration, say goodbye to
Serverless deployments, and have fun dockerizing a Servlet that expects to be in control of the
machine it's running on!

## Environment Variables for Configuration

Aside from being #3 on the [12 Factor App](https://12factor.net/) manifesto, pushing configuration to
environment variables prevents a host of weird startup bugs that prove to be quite difficult to debug.


## Upgrade Your Build Tool

Maven and Gradle have come a _long_ way. There are newer, flashier build tools out there, as well,
but I've found Maven and Gradle to be great bang for the buck. They're well supported, well
documented (Googlability metric for the win!), they [both](https://github.com/takari/maven-wrapper) [have](https://docs.gradle.org/current/userguide/gradle_wrapper.html) wrappers that allow
someone new to checkout the code and build immediately, and they both have a lot of tooling built around
them. Seriously, just look at the [Gradle Plugins Page](https://plugins.gradle.org/).

I've encountered some weird build tooling in the wild. Ant is still around, random bash scripts wrapping javac
and their own dependency management, it's all a lot of effort for, in my opinion, very little ROI. If
you fall into the category of "massive code base, need better solution", give Bazel a try!

## Upgrade Your Dependencies

This one is a real kicker because it can sometimes kick you back...hard. I'm not actually
advocating to be on the bleeding edge. I've done that enough. I am, indeed, still bloody (
but happy!). What I'm mostly picking at is enabling the ability to upgrade. I see _a lot_ of
people using Postgres but sticking to pre-version 9. I still see Spring Boot 1.4 and lower in
Production (we're in 2.0 here in 2020).

Even if you can't do a major version change yet for some reason, stay
on top of those minor versions. I've observed most big libraries keeping to the SemVer rules of
"don't break APIs in minor versions". Check your changelogs, just to be sure, but keep those
dependencies updated!

## Error Handling != Exceptions

This one is laced with opinion, I admit. It's been drilled into me with Functional
Programming. But it has genuinely has changed my Java career. When I stopped throwing exceptions as
a form of normal error handling, and kept exceptions for _exceptional cases_, my code became so much
easier to follow. Keeping the callstack in my head while reading code is awful, and then trying to
trace where something actually gets caught and handled usually involves running the code. That's not
a very ergonomic way to read code.

This may add more models to your stack, and that's OK (you using Lombok yet?). Proper error
modeling forces you to really understand both the happy and error paths of your code, and encode them accordingly.
It also makes it _very_ explicit what errors you expect and where. This has cleaned up code,
reduced the amount of context I have to keep in my head when reading code, and has come with
a much nicer Production Support experience since random Exceptions on normal requests can't bring down
the server.

And I have to call this one out. _Stop throwing RuntimeExceptions for normal errors_.
If you are throwing RuntimeException because you don't want to add `throws` to all your
methods, you've probably not handled that error properly! And you create a nightmare of a
debugging session for the developer who gets that bug report. It might even be you...

## Upgrade Your JDK

_Seriously_. I know there are _some_ companies that are truly stuck on older JVMs for various
reasons, and to you I apologize. Even just getting up to Java 8, if you aren't
already, unlocks a host of quality-of-life improvements. Streams? Optionals? Better garbage
collection? _Lombok_?? A lot of the larger projects don't even support before Java 8 anymore.

I bring this one up, slightly tongue-in-cheek, because I've encountered a surprising number of
shops that haven't updated to later versions because "we don't need the new features". This is
a fantastic way to create chaos for your developers and they won't thank you for it. Try downloading
an updated JDK for Java 7. It's an awful experience that forces all kinds of workarounds in local
tooling.

## Conclusion

Java is often criticized for being a boring, verbose, esoteric language that's falling behind more
modern equivalents. But with a few changes to your process, your tool chain, or your paradigm,
it can actually be a _decent experience_. Still not quite as good as Golang, though...

Hope this helps! Thanks for stopping by the Lab!
