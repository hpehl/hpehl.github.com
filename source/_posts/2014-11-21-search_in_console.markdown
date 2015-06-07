---
layout: post
title: "Local Search in the Management Console"
date: 2014-11-21 10:21
comments: true
categories: console jboss hal search
---
Today [WildFly 8.2.0.Final](http://wildfly.org/news/2014/11/20/WildFly82-Final-Released/) was released. It comes with a number of improvements and bug fixes over the last release, 8.1.0.Final. Regarding the management console, Heiko Braun already gave a glimpse of some of new features in his recent [blog post](http://hbraun.info/2014/10/updated-management-console-in-wildfly-8-2/). Today I'd like to introduce yet another feature which was introduced in WildFyl 8.2: Local Search.<!-- more -->

With every new feature added to WildFly, the number of screens and options in the management console grows as well. Sometimes it's hard to quickly find the right screen where you can modify your JMS topics or monitor that data source connection pool. That's why we added a search feature to the management console. It's built around the idea to have an index which contains reasonable keywords and the descriptions from the underlying [management model](http://wildscribe.github.io/).

It's super fast, because the index is built and stored locally inside the browser. That's why you need a modern browser with support for [local storage](http://caniuse.com/#search=localstorage) to use the search. Don't worry about the size of the index, it's quite compact: For WildFly 8.2 running in domain mode the index will be roughly 10 KByte large, so it's no a big deal to keep the index in local storage. For those who want to know all the nitty-gritty details, the local search is based on the JavaScript framework [lunr.js](http://lunrjs.com/). In a nutshell lunr.js is slimmed full-text search engine ready to be used in your browser. But enough with all these implementation details. Let's see how this all works:

To enter the search press the search link in the upper right corner of the management console:

{% img centered /images/posts/local_search_header.png Local Search %}

The first time you enter the search, the index is automatically created based on the WildFly version, the operation mode (standalone or domain) and the language. During index creation the descriptions of the management model is fetched from the server side and stored in the index. Depending on your setup and network latency this make take a few seconds.

{% img centered /images/posts/local_search_index_setup.png Indexing... %}

Once the index is ready you can start searching. As you type your query the results will update dynamically:

<iframe width="420" height="315" src="https://www.youtube.com/embed/wdb3W-G-9WI" frameborder="0" allowfullscreen></iframe>

<br/>
Give the new local search a try and let us know what you think!
