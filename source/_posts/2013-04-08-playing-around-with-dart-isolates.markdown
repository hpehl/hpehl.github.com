---
layout: post
title: "Playing around with Dart Isolates"
date: 2013-04-08 22:26
comments: true
categories: dart
---
I was looking for a way to implement some kind of dynamic plug-in system in Dart. The idea was to load Dart code on
demand into an isolate using [spawnUri()](http://api.dartlang.org/docs/releases/latest/dart_isolate.html#spawnUri).
It turns out that this function is implemented in the Dart VM but neither in Dartium nor does it compile down to
JavaScript.<!-- more -->

Falling back to [spawnFunction()](http://api.dartlang.org/docs/releases/latest/dart_isolate.html#spawnFunction) works
as expected in the browser but it turns out that isolates are not allowed to access / change the DOM. This reduces
isolates to dumb worker functions. Plug-ins which make contributions to the UI are not possible using this approach.

I created some test scripts for the browser and the VM to test the possibilities you have with isolates. You can
find them at GitHub: [https://github.com/hpehl/dart-isolates](https://github.com/hpehl/dart-isolates). Let me know what
you think.