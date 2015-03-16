---
layout: post
title: "Standalone Management Console"
date: 2015-03-16 16:00
comments: true
categories: 
---
Back in 2013 I wrote about an idea to have an [independent management console](/independent-jboss-admin-console.html) which can connect to arbitrary servers. Starting with WildFly 9 we finally have the technical prerequisites to ship such a console. In this blog post I will describe how to configure and launch an independent management console.<!-- more -->

As you might know the management console is developed using GWT and compiles down to a bunch of HTML, JavaScript and CSS files. Until now these artifacts were a fixed module of each WildFly version. WildFly serves the console and the console talks to the same origin it was loaded from. This still holds true. 

However starting with WildFly 9 the HTTP endpoint for the management interface supports the configuration of so-called allowed origins. This list - which is empty by default - contains URLs which are allowed to access the management interface (see http://en.wikipedia.org/wiki/Cross-origin_resource_sharing for more details). This setup is necessary to cope with the [same origin policy](http://en.wikipedia.org/wiki/Same_origin_policy) (SOP) when the console is served from origin A, but talks to the management interface at origin B.   

Equipped with these features we can now launch the management console from any URL and connect to any management which has this URL configured as an allowed origin. To make things simple, we've setup an [HAL build proxy](http://access-halproject.rhcloud.com/) on OpenShift. This proxy is able to fetch any console version from the public JBoss maven repository and serve it using a distinct URL. It offers a list of simple HTTP endpoints:
 
| URL                  | Description                                                      | Example                                                       |
|----------------------|------------------------------------------------------------------|---------------------------------------------------------------|
| `/latest`            | Displays the version of the latest HAL release                   | http://access-halproject.rhcloud.com/latest                   |
| `/releases`          | Gets the list of supported HAL releases (w/o snapshots)          | http://access-halproject.rhcloud.com/releases                 |
| `/release/:version`  | Serves a specific HAL version (only works with version > 2.6.x)  | http://access-halproject.rhcloud.com/release/2.6.5.Final      |
| `/snapshot/:version` | Serves a specific HAL snapshot (only works with version > 2.6.x) | http://access-halproject.rhcloud.com//snapshot/2.7.0-SNAPSHOT |

If you don't want to use the prebuilt proxy on OpenShift, you can also checkout the source code and run your own build proxy:
 
1. Clone the registry from https://github.com/hal/mvn-repo-server
1. Build the proxy with Maven: `mvn clean package` (requires Java 8)
1. Start the proxy: `java -jar target/server-jar-with-dependencies.jar` (by default port 8080 is used)
1. Open http://localhost:8080/

# Allowed Origins Setup

Whether you use the prebuilt proxy on OpenShift or build your own, you have to add the URL of the standalone console to the list of allowed origins. Depending on the operation mode use one of the following CLI commands:

- standalone mode: 

        /core-service=management/management-interface=http-interface:list-add(name=allowed-origins,value=http://access-halproject.rhcloud.com)
        reload
    
- domain mode:

        /host=master/core-service=management/management-interface=http-interface:list-add(name=allowed-origins,value=http://access-halproject.rhcloud.com)
        reload --host=master


# Console Configuration

When you open the console it detects whether it is part of a WildFly instance or launched independently. In the latter you need to specify a management interface you like to connect to. You can manage a list of different interfaces running on different WildFly instances. The configuration is stored in the browser's local storage, so it's available the next time you open the console. 

Say you want access your local WildFly instance using the HAL management console 2.6.5.Final served from the build proxy. In order to do so, follow these steps:

1. Point your browser to http://access-halproject.rhcloud.com/release/2.6.5.Final

1. Click 'Add' to configure a management endpoint.

  ![Connect to Management Interface](/images/posts/bootstrap_server_select_0.png)
  
1. Add the hostname and port of you local WildFly instance. You can verify your settings using 'Ping'.

  ![Connect to Management Interface](/images/posts/bootstrap_server_select_1.png)
  
1. Click 'Connect' to finish.
 
  ![Connect to Management Interface](/images/posts/bootstrap_server_select_2.png)
  
You can use an existing configuration using the `connect` query parameter. For the above example this url is a shortcut and will skip the bootstrap dialogs: http://access-halproject.rhcloud.com/2.6.5.Final/App.html?connect=local

## Limitations and Known Problems

When using the standalone console there are some pitfalls and preconditions you should be aware of:
 
- The standalone console can only connect to WildFly 9.x and above.
- Make sure to configure the allowed origins before connecting from the standalone console.
- Don't use different schemes (https and http) for the standalone console and the WildFly instance you want to connect to.
- In rare cases it might be necessary to clear the cache or use the browser's private mode when switching between different WildFly instances. 
