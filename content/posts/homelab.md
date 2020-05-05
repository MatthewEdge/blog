+++
date = "2020-04-08"
title = "Homelab Revamp"
author = "{{ .Site.Author.name }}"
description = "Rebuilding a cherished past time"
draft = true
+++

Building a homelab has been a past time of mine for years. It started
by repurposing an old Lenovo desktop computer as a LAMP host, escalated when I built
a GPU Compute cluster for my college exit project, and has stuck with me, in many forms,
ever since.

Recently I decided to revamp my homelab. The row of Raspberry Pis and the SoPINE Compute
board was really nice for small projects but I found a number of limitations on ARM architecture
when I dove into new DevOps fanciness or new home automation attempts. I wanted something
powerful enough to support my tinkering, yet compact enough (and quiet enough) that I could
keep it in my closet. After a lot of ideation - I decided to repurpose my existing Threadripper
desktop as the virtualization box and rebuild a smaller, purpose-built gaming desktop to replace it.

## Why not a cloud environment?

Getting rid of the hardware closet for a cloud-based workflow came up _a lot_ when discussing this idea
with others. I pondered it, personally, many times as I scrolled through Newegg for parts and seeing the
total cost to rebuild.

For me it came down to:

- I like to play with the hardware
- I wanted to be able to leave it running, DDoS my applications, forget to clear out data/logs, and not have it cost a literal fortune
- The joy of figuring out how to actually deploy a complex system from zero

## Play and Learn from Hardware

Personally, half the fun of a DIY homelab is the learning aspect.
I am responsible for all aspects of this homelab and, consequently, I've had to learn _a lot_ about
system administration, hardware failures, and resource scrutiny. I got real comfortable with the command
line and Linux utilities as a result. And the benefit? _Automate all the things_.

DIY sysadmin and hardware curating has also affected my development life. I have a bit of a minimalist
attitude, now, to what my application _should_ need in terms of resources, I have a greater appreciation
for things like structured logs, Quality of Life items like health checks that are actually CLI-readable,
and simple deployment pipelines. I probably wouldn't have gotten the same exposure without my homelab. And
the obsession with automating as many aspects of development as possible also comes from messing around with
this homelab.

## Cost

Cost seems to come and go into the equation in waves. And with that rotation of thought - the cloud comes up.
I have dealt with AWS and GCP the most in my day job. They're fantastic resources for company work...but I always
find myself worrying about cloud costs suddenly skyrocketing. Oops...forgot to shut down that compute cluster....
that'll be \$100 for 4 days please.

My homelab, on the other hand, is _mostly_ upfront cost. And for a tinkering workload - reserved cloud instances don't
make as much sense to me. I like being able to randomly spin up projects, like a Kubernetes cluster, play with it, and
then tear it down in favor of the next tinker. I also have a bit of a fascination with finding the limits of an application
stack in terms of traffic / coordination. A.k.a - I like to DDoS my services and see how they react. In a cloud
environment this can be a _very_ expensive hobby. In my homelab - the closet is my oyster, so long as my network can handle
it.

My homelab currently consists of:

- Ubiquiti routing, switching, and wireless Access Points
- A row of Raspberry Pi 4s
- And my "old" desktop

I mostly ignore the networking gear because that was a bit of a splurge. But I include it to cite that,
internally in my house, I get a 1Gbps network to play with. The Pis (4 of them) add 4 low-power cores,
4GB RAM, and about 60GB of flash storage each. The "old" desktop was my Threadripper build that I built
from a lucky buy on the CPU. It's 16 cores, 64GB RAM, and now houses about 12TB of storage. That's a lot
of compute power that also gets used for home automation tasks.

Grand total I believe that hardware cost me $1000. I bought the desktop 3 years ago and bought the Pis
about a year ago. If I had been _very_ careful with a cloud Account I could have had the similar compute
power for, according to AWS, about $200 a month. That doesn't take into account misc. costs like data
transfer, storage, etc. That's just compute. On my homelab - those misc. costs don't exist with the
exception of electricity and AC. Maybe those balance each other out...

Am I retroactively justifying buying a 16 core, 64GB RAM desktop? Just a little bit.

## Isolation

Isolation has a couple boons.
