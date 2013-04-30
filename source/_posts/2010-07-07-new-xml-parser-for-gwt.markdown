---
layout: post
title: "New XML parser for GWT"
date: 2010-07-07 13:31
comments: true
categories: xml totoe
---
I'm pleased to announce the first release of [Totoe](https://github.com/hpehl/totoe). Totoe is a XML parser for GWT 
which comes with XPath and namespace support. It originated from Piriti a JSON and XML mapper for GWT.<!-- more -->

Totoe uses [Sarissa](http://dev.abiss.gr/sarissa/) for the XML parsing. Sarissa is a great cross browser XML parser 
for Javascript. Essentially Totoe is a GWT port of Sarissa with the goal to offer a similar API as the GWT XML module. 
Right now the focus is on parsing XML - there are no methods to create, insert or append documents, elements or nodes. 
Those features might come in later releases. The big advantage over the GWT XML module is IMHO a cleaner API and the 
support of XPath and namespaces.