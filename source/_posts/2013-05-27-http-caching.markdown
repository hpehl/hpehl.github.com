---
layout: post
title: "HTTP Caching"
date: 2013-05-27 21:14
comments: true
categories: http cache
---
I recently implemented caching for distinct operations of the 
[HTTP management API](https://docs.jboss.org/author/display/WFLY8/The+HTTP+management+API) in 
[WildFly](http://www.wildfly.org/). As a preparation I did some research on HTTP caching and how it's best 
implemented on the server side. A really good introduction is the 
[caching tutorial](http://www.mnot.net/cache_docs/) by Mark Nottingham. I'll discuss the key points in this 
blog post.<!-- more -->
 
# Terminology
A cache sits between one or more servers (also known as _origin_ servers) and a client watching requests and saving 
responses (also known as _representations_). There are different kind of caches: 
   
- browser caches
- proxy cahces
- gateway caches

The cache I want to look at in more detail is the browser cache. Every browser uses a section of your hard disk 
to store representations that you've seen. The browser will check to make sure that the representations are fresh, 
usually once a session (that is, the once in the current invocation of the browser). 

# Rules for Caching

There are certain rules used to decide when to serve a representation from the cache. 

1. If the response’s headers tell the cache not to keep it, it won’t.
3. A cached representation is considered fresh (that is, able to be sent to a client without checking with the origin server) if:

	- It has an expiry time or other age-controlling header set, and is still within the fresh period, or
	- If the cache has seen the representation recently, and it was modified relatively long ago.
	
	Fresh representations are served directly from the cache, without checking with the origin server.
4. If a representation is stale, the origin server will be asked to validate it, or tell the cache whether the copy that it has is still good.
5. Under certain circumstances — for example, when it’s disconnected from a network — a cache can serve stale responses without checking with the origin server.

There are two key players when it comes to apply these rules: _freshness_ and _validation_. A fresh representation will 
be available instantly from the cache, while a validated representation will avoid sending the entire representation 
over again if it hasn’t changed.

# Freshness

Freshness of a resource can be controlled using various HTTP _response_ headers. 

- `Pragma` &mdash; The HTTP sepcification does not set any guidelines for `Pragma` response headers; instead it 
discusses `Pragma` _request_ headers. Using this header will most likely have no effect and the recommendation is to 
use the headers below.

- `Expires` &mdash; Using the `Expires` header you can tell a cache how long the representation will be fresh. After 
that time, caches will always check back with the origin server to see if a representation has changed. The only value 
valid in an `Expires` header is a [HTTP date](http://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html#sec3.3.1) which is 
based by definition on GMT.

    Because the `Expires` header includes an absolute date and time, the clocks on the origin server and the cache must 
be in sync. If they have a different idea of the time, caches might consider stale representations as fresh. This is 
the reason you're better off using the `Cache-Control` header.

- `Cache-Control` &mdash; Starting with HTTP 1.1 you can use the `Cache-Control` header to manage caching. The header 
uses many different parameters. I will discuss the most common (see the 
[HTTP secification](http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.9) for a complete list of parameters):

    - `max-age=[seconds]` &mdash; specifies the maximum amount of time that a representation will be considered fresh. 
      [seconds] is the number of seconds from the time of the request you wish the representation to be fresh for.
    - `no-cache` &mdash; forces caches to submit the request to the origin server for validation before releasing a 
      cached copy, every time. This is useful to maintain rigid freshness, without sacrificing all of the benefits of 
      caching.
    
When both `Cache-Control` and `Expires` are present, `Cache-Control` takes precedence. Whenever possible, I recommend 
to use `Cache-Control`.

# Validation

Validation is used by the cache to check if a representation has changed. By using it, caches avoid having to download 
the entire representation when they already have a copy locally, but they’re not sure if it’s still fresh. Validators 
are very important; if one isn’t present, and there isn’t any freshness information (`Expires` or `Cache-Control`) 
available, caches will not store a representation at all.

Basically there are two response headers for validating representations:

- `Last-Modified` &mdash; A [HTTP date](http://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html#sec3.3.1) stating the 
last modification date of the representation. When a cache has a representation stored that includes a `Last-Modified` 
header, it can use it to ask the server if the representation has changed since the last time it was seen, with an 
`If-Modified-Since` request. 

- `ETag` &mdash; An unique identified for the representation. Something kind of hashcode. The ETag must change every 
time the representation does. The cache can ask the server using a `If-None-Match` header whether the representation 
has changed. 

If the representation did not change the origin server should respond with an empty 304 - not modified response.

# References

All headers, parameters and rules for HTTP caching are described in great detail in an own chapter of 
the [HTTP specification](http://www.w3.org/Protocols/rfc2616/rfc2616-sec13.html). If you plan to implement HTTP caching 
in one way or another it's a very useful reference.
