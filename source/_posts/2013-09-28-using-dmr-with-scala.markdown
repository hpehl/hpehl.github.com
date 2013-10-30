---
layout: post
title: "Polyglot DMR"
date: 2013-09-28 00:20
comments: true
categories: jboss dmr scala dart node.js
---
The __d__ynamic or __d__etyped __m__odel __r__epresentation (DMR) is an API to interact with the management model of a 
running WildFly instance. There's an Java API available at <https://github.com/jbossas/jboss-dmr> which is described in 
the [WildFly Wiki](https://docs.jboss.org/author/display/WFLY8/Detyped+management+and+the+jboss-dmr+library). Though 
the Java API is very rich and powerful it is somewhat hard to write scripts that perform useful tasks like

- Periodically read the memory and send an SMS / tweet / email when a threshold is reached
- Rollout a deployment over all servers in a cluster
- Monitor the state of an application<!--more-->  

To address this challenges we created different client libraries for different languages:
  
# Scala
The scala library is hosted at [DMR.scala](https://github.com/hpehl/dmr.scala). The 
[DMR.repl](https://github.com/heiko-braun/dmr-repl) library leverages the Scala REPL to execute DMR operations in 
a very interactive way.

# Dart
Using [DMR.dart](https://github.com/hal/dmr.dart) you can run DRM operations in Dart. Both executing individual 
operations, as well as writing whole web applications is possible. 

# Node.js
The library for Node.js is called [DMR.js](https://github.com/hal/dmr.js).  

# Ideas
Bringing the DMR library to different languages opens up many possibilities. We can think of a repository with 
(parameterized) management scripts, an integration with Gist / Paste.bin to quickly share your operations with 
your co-workers, ... We'd love to heear your feedback and suggestions on this!

# Open Issues
One of the main challenges when using the different client libraries is authentication. Right now there's a workaround 
to use a [CORS enables JBoss AS instance](/independent-jboss-admin-console.html) which is however a bit out of date. 
IMO the solution for this is to bring OAuth support to WildFly. For the time being the usage of the client libraries is 
somewhat limeted and if any feasible when running on the same host. 

# Conclusion
The different libraries are very much work in progress, but we'd love to here your feedback!
