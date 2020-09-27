+++
date = "2020-09-27"
title = "Automate Dev with Docker"
author = "Matthew Edge"
description = "Using Docker to automate dev tasks"
draft = true
+++

During one of my live stream sessions this past week, I had a couple
viewers request a demo of how I use Docker in my development work. A lot
of them seemed to have the perception that Docker was only, really, for
deploying code. While this is a huge benefit (and one I try to suggest
anywhere it can make sense), there is also a local benefit to Docker:
automating dev-related tasks. Docker, combined with a couple other tools,
can be used to create a mostly-automated environment to allow you to focus
more on the code! And I like focusing on code.

## Tool Installation

Developers use _a lot_ of tools. We have tools for compiling code, tools for
testing, tools for building and monitoring infrastructure, tools for writing
blog posts (thanks, Hugo!), even tools for ensuring our tools are up to date!

Tools come with installations. Installations come with configuration. Configuration
must be remembered, documented, duplicated for the rest of the team.... it's enough
to make anyone's head spin. Even worse, you probably use those tools once in a
Blue Moon? When was the last time you ran the Cypress test suite? ...seriously,
when was the last time? Show it some love!

For example: for the infrastructure side of many of my recent projects we have
used Terraform for infrastructure automation. I'm usually not messing with
Terraform much, but we had a couple `tf` files for spinning up our DEV
environment. I wanted to spin up an isolated copy of DEV for some very disruptive
chaos testing, so I wanted to run the Terraform scripts.

To do so, I needed:

* Terraform CLI
* Credentials (gotta have that AWS access!)
* Environment variables set (??)
* Knowledge of `terraform init` vs `terraform plan` vs `terraform apply` (Thanks, Frank!)
* A healthy dose of Google-fu

Not _uncommon_ when using new tools, but that's a lot of context, configuration, and
brain space to simply _use_ what the team had created.

### First - write some Bash?

My first instinct is, usually, to wrap such tasks in Bash.

## Automate Data Stores

Databases, volumes for persistent data

## Automate Labs

Dev environments, build servers, webhooks
