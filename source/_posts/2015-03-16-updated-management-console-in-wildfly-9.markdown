---
layout: post
title: "Updated management console in WildFly 9"
date: 2015-03-16 22:44
comments: true
categories: jboss console wildfly9
---
The upcoming WildFly 9 release will include an improved HAL management console based on the [2.6.x branch](https://github.com/hal/core/tree/2.6.x) branch.

The improvements at a glance:

- New subsystem configuration: Remoting
- Support for datasource templates.
- Provide all flush-* operations for connection pools
- Improved log viewer
- Enhanced model browser
- Get more details about applied patches
- Standalone console
<!-- More -->

# Remoting subsystem

The remoting subsystem was added to the console. You can now configure remote (http) connectors and outbound connections.

{% img centered /images/posts/remoting_subsystem.png Remoting subsystem %}

# Datasource Templates

The management console provides for the datasource most commonly used templates with reasonable default settings. These presets include JNDI names, driver settings, datasource properties and highly specific options like validation checkers and exception sorters.

{% img centered /images/posts/datasource_templates.png Datasource templates %}

# Improved Log Viewer

WildFly 8.2 featured a log viewer which allowed you to browse through or tail server logs. Now you can view the log file as a whole in the console and search for specific text. Optionally you can download the full log file and open it in an external editor of your choice.

{% img centered /images/posts/improved_log_viewer.png Improved log viewer %}

# Standalone Console

Starting with WildFly 9 and [HAL 2.6.5.Final](http://hal.gitbooks.io/dev/content/release-coordination/versions/2.6.5.Final.html) the management console can be launched independently from WildFly. Take a look at my [last post](/standalone-management-console.html) for more details.
