---
layout: post
title: "WildFly Dockerfiles"
date: 2013-11-28 14:40
comments: true
categories: jboss widfly docker
---
For the last couple of days I have been playing with [Docker](http://www.docker.io). In a nutshell Docker is a tool
that lets you create images and run so called containers. It uses [Linux Containers](http://lxc.sourceforge.net/) (LXC)
under the hood. What appears to be yet another virtualization solution, is in fact a very lightweight way to setup,
manage and run "processes in a box".<!-- more -->

Docker comes with a great [tutorial](http://www.docker.io/gettingstarted/) and a
reasonable [documentation](http://docs.docker.io/en/latest/). So I won't go into any details here. There are also some
very good [posts](http://goldmann.pl/blog/tags/docker/) from [Marek Goldmann](http://goldmann.pl/blog/) which helped
me a lot getting started. In the remaining part of this post I will show you how to setup both a WildFly standalone
server and a domain with multiple hosts and servers. Here we go!

# Preperations

I assume you already have installed Docker. If not please refer to the
[offical documentation](http://www.docker.io/gettingstarted/#h_installation) on how to setup Docker on your machine.
The following assumes you're using Docker 0.7.0.

I've put together a repository which is based on Ubuntu and contains Java7 and WildFly 8.0.0.Beta1. It does not contain
any commands or entrypoints, but is intended to serve as a base repository for the other WildFly related repositories.
You can grap it and use it as a starting point:

```
$ docker pull hpehl/wildfly
$ docker run -i -t hpehl/wildfly /bin/bash
```

# Standalone

To quickly run a standalone server, I've put together the repository `hpehl/wildfly-standalone`. It is based on
`hpehl/wildfly` and starts an unmodified standalone server. The standalone server exposes the following ports:

- 8080 for HTTP
- 9990 for HTTP based management and
- 9999 for native management

You can use the user `admin:passw0rd_` to access the management interfaces. Running it with

```
docker run -p 49080:8080 -p 49090:9990 -d hpehl/wildfly-standalone
```

will start the server. You can check the status with `docker logs <CONTAINER_ID>`. After a short while you should
be able to access the server using http://localhost:49080

{% img centered /images/posts/docker_wildfly_standalone.png WildFly standalone server running inside a Docker container %}

# Domain

To setup a domain use the repository `hpehl/wildfly-domain`. It contains different tags to start a domain controller
and up to four hosts. Tags are a way to reference different images inside a repository. The syntax for tags is
`<repository>:<tag>`. When no tag is given, Docker uses the tag `latest`. The domain repository consists of these tags:

- `hpehl/wildfly-domain:dc`: The domain controller with five servers. The domain controller defines three server groups:
  - deployment
  - staging
  - production
- `hpehl/wildfly-domain:hostA`: First host with three servers
- `hpehl/wildfly-domain:hostB`: Second host with three servers
- `hpehl/wildfly-domain:hostC`: Third host with two servers
- `hpehl/wildfly-domain:hostD`: Fourth host with two servers

Docker has a great feature which enables inter-container communication. This is done by specifying the `link`
parameter. When linking two containers Docker will use the exposed ports of the container to create a secure tunnel
for the parent to access. This feature is used in the WildFly domain for the communication between the domain
controller and the hosts.

In order to setup and run the domain, you have to first start the domain controller. After that you can start as many
hosts as you like and link them to the domain controller. Be sure to use "dc" as name (using another name won't work):

    docker run -name wildfly-dc -d hpehl/wildfly-domain:dc
    docker run -name hostA -link wildfly-dc:dc -d hpehl/wildfly-domain:hostA
    docker run -name hostB -link wildfly-dc:dc -d hpehl/wildfly-domain:hostB
    docker run -name hostC -link wildfly-dc:dc -d hpehl/wildfly-domain:hostC
    docker run -name hostD -link wildfly-dc:dc -d hpehl/wildfly-domain:hostD

Some notes:

- The domain controller exposes the standard ports
  - 8080 for HTTP
  - 9990 for HTTP based management and
  - 9999 for native management
- The hosts expose just port 8080
- The domain controller defines the user `admin:passw0rd_`, which can be used for management

# Troubleshooting

Unfortunately in the current WildFly Beta there's a problem if you want to access the admin console of a WildFly
instance running inside a Docker container. I assume this will be fixed once WildFly GA is available. For the time
being you can only use the CLI.

If you need the console, you can use for instance EAP 6.2 which is not affected by this
limitation. You can find [Dockerfiles](https://github.com/hpehl/dockerfiles/tree/master/eap62) on my GitHub account
using EAP. However please note that there's no EAP distribution included. You have to provide one on your own.

# Summary

Using Docker it is really easy to setup a WildFly domain. Adding / removing hosts is just a matter of
starting / stopping Docker containers.

Docker offers also a rich API. So setting up your domain could also be done using a nifty web front-end where you
'click together' your server groups, hosts and servers. The Dockerfiles, images and containers would then be created
based on your input - all fully automatically!

# Resources

- WildFly repositories on index.docker.io: https://index.docker.io/u/hpehl/
- Related Dockerfiles: https://github.com/hpehl/dockerfiles/tree/master/wildfly
