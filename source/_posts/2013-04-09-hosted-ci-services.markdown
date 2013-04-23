---
layout: post
title: "Hosted CI Services"
date: 2013-04-09 15:31
comments: true
categories: 
---
I was looking for a hosted continuous integration service to build my GitHub projects. My requirements are painless
GitHub integration, easy setup and a simple and straightforward UI. I looked at two services:
[Drone.io](http://drone.io/) and [Travis CI](https://travis-ci.org/). In this post I will outline my very personal
experience with it.

Both Drone.io and Travis CI offer very good GitHub integration. It's fairly simple to connect your GitHub projects.
Especially Drone.io does a very good job. Link your GitHub account, choose your project and language and you're ready
to go.

Unfortunatley neither Drone.io nor Travis CI can deploy artifacts to external repositories like OSS Sonatype out of
the box (though there's a [workaround](https://gist.github.com/neothemachine/4060735) for Travis). By now I'm building
and deploying dependent projects manually from my box.

To sum it up these are pros/cons for me:

1. Drone.io
    * Pros
        - Very simple and easy to use UI.
        - Great GitHub integration
        - Supports alos BitBucket and GoogleCode
    * Cons
        - Once a job / project was setup you cannot delete it anymore (as least I don't know how?)
        - Limited configuration options
2. Travis CI
    * Pros
        - Powerful configuration options (.travis.yml)
        - Great range of supported languages
        - Supports multiple JVM
    * Cons
        - Some extra configuration steps to get started

Feel free to totally disagree with me or comment your own experience.

**Update**
You can delete a project in Drone.io by going to your project's Settings &gt; Repository page. Thanks for the hint Brad.
