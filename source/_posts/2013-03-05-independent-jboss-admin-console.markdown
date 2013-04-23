---
layout: post
title: "Independent JBoss Admin Console"
date: 2013-03-05 21:43
comments: true
categories: jboss console
---
We're currently working on a new feature for the JBoss Admin Console. The console should become independent from the
rest of the JBoss AS distribution. As the console is built with GWT and "merely" consists of static resources like
HTML, JavaScript and CSS, the idea is to have a dedicated host which serves these resources. When loading the console
the user can manage a list of server instances and chooses the one he likes to connect to. The server instances are
stored in the browsers [local storage](http://www.w3.org/TR/webstorage/), so they will be available the next time the
console is launched:

{% img /images/posts/select_server_instance.png %}

Using this kind of setup brings us several advantages:

* We can update the console independently from the rest of the AS code base
* We can deploy the console to various (web)app stores like Firefox Marketplace or Chrome Web Store
* We can have different console versions with different feature sets (nightly, beta, stable)
* Using one console you can connect to different server instances running different setups (development, staging, production)

# CORS
The console talks to the domain controller (DC) using the HTTP management API. Now when the console and the DC live
on different hosts, the [same origin policy](http://en.wikipedia.org/wiki/Same_origin_policy) (SOP) throws a monkey
wrench in our efforts. Luckily we're not the first ones confronted with this problem. There are several ways to solve
SOP restrictions:

* Server Side Proxies
* [JSON with padding](http://en.wikipedia.org/wiki/JSONP) (JSONP)
* [Cross-Origin Resource Sharing](http://www.w3.org/TR/cors/) (CORS)

## Client
According to [caniuse.com](http://caniuse.com/#search=cors) CORS is implemented in most of the browsers. CORS knows
two different types of requests.

1. Simple requests:

    A request that only uses `GET` or `POST`. If `POST` is used to send data to the server, the content type of the data
sent to the server with the HTTP `POST` request is one of `application/x-www-form-urlencoded`, `multipart/form-data`
or `text/plain`. The request must not contain custom headers (such as `X-Modified`, etc.)

2. Preflighted requests

    A request that uses methods other than `GET` or `POST`. Also, if `POST` is used to send request data with a
content type other than `application/x-www-form-urlencoded`, `multipart/form-data` or `text/plain`, e.g. if the
`POST` request sends an XML payload to the server using `application/xml` or `text/xml`, then the request is a
preflighted request. Furthermore if the request contains custom headers, it's preflighted.

Unlike simple requests, preflighted requests first send an HTTP `OPTIONS` request header to the resource on the other
domain, in order to determine whether the actual request is safe to send. Since the console uses `POST` with a
content type of `application/dmr-encoded` all requests are preflighted requests. This will be important when looking
at the server side.

Common to all requests is that the browser adds the request header `Origin`. The value of this header is the site
that served the page. For example, suppose a page on http://www.example-social-network.com attempts to access a
user's data in online-personal-calendar.com. If the browser implements CORS, the following request header would be sent:

    Origin: http://www.example-social-network.com

## Server
It is up to the server to decide which origins are allowed. When the server accepts cross-origin requests, it sends an
`Access-Control-Allow-Origin` header in its response. The value of the header indicates what origin sites are allowed.
For example, a response to the previous request would contain the following:

    Access-Control-Allow-Origin: http://www.example-social-network.com.

For the JBoss AS this implies changes to the class `org.jboss.as.domain.http.server.DomainApiHandler`. This class
handles HTTP requests to the management API. The modified version accepts preflighted `OPTIONS` requests and sets the
relevant response headers.

## Authentication
The console uses digest authentication. This must continue to work when doing cross-origin requests. By default,
in cross-origin `XMLHttpRequest` invocations, browsers will not send credentials. A specific flag called
`withCredentials` has to be set on the `XMLHttpRequest` object when it is invoked. Unfortunately GWTs implementation
of the JavaScript `XMLHttpRequest` object does
[not yet implement](https://code.google.com/p/google-web-toolkit/issues/detail?id=7677) this flag. For the time being
we need to include `withCredentials` by ourselves.

The next challenge is to trigger the login dialog when accessing protected resources. Unfortunately when it comes to
authentication browsers handle CORS quite differently. There are some workarounds depending on which browser is used:

* Chrome [prevents basic authentication from a different origin as a phishing attack](http://blog.chromium.org/2011/06/new-chromium-security-features-june.html) period.
The only way to get around that is to start Chrome using the command line option `--allow-cross-origin-auth-prompt`.
* Firefox makes no problems when it comes to display the login dialog (well done guys!)
* Safari won't show the login dialog. You can get around that by inserting a hidden `<iframe>` element linking to the
protected url. This will trigger the authentication popup and once the user has authenticated, you can execute direct
`XMLHttpRequests` as usual.
* Internet Explorer somewhat support CORS in IE8 and IE9 using the `XDomainRequest` object (but has limitations).

Finally there's an issue related to preflighted `OPTIONS` requests on the server side. According to the specification
those requests must

> exclude user credentials.

Hence these requests are blocked by the server with "401 Unauthorized". As a workaround the authenticators in the AS
code base must let pass preflighted `OPTIONS` requests.

## Status Quo
At the moment a first preview of an independent console is available at
OpenShift: [https://console-hpehl.rhcloud.com](https://console-hpehl.rhcloud.com). Please note that you must have a
CORS enabled server instance running in order to connect from the console. You can build one by yourself using the
"cors" branch of the AS code base: [https://github.com/hpehl/jboss-as/tree/cors](https://github.com/hpehl/jboss-as/tree/cors).
Follow the steps in the [README](https://github.com/hpehl/jboss-as/tree/cors#readme) to build the server.

Due to the limitations regarding authentication and CORS, the solution described here will only work in Firefox and
Safari. If you want to use Chrome make sure to use the `--allow-cross-origin-auth-prompt` command line option.
