---
layout: post
title: "Paging in Resources"
date: 2010-09-13 11:21
comments: true
categories: rest
---
A common requirement for resources which return large collections of records is paging. Paging can be implemented in 
many different ways. <!-- more -->See the following pages as an entry point to the discussion:

* [Stackoverflow](http://stackoverflow.com/questions/924472/paging-in-a-rest-collection)
* [DOJO](http://docs.dojocampus.org/dojox/data/JsonRestStore#paging)

In the following sections I will introduce three different solutions. All of them are implemented in 
[Taoki](https://github.com/hpehl/taoki) - a small extension for [Restlet](http://www.restlet.org).

### Template Parameter
This implementation uses parts of the url to carry the paging information:

    GET /books
    GET /books/0/50
    GET /books/0/50/author/asc
    
The advantage of this implementation is that the resource can be cached by proxies. The drawback is that a lot of 
template parameters are "wasted". For example /books/report/{quarter} won't be available as route, since it is 
occupied by /books/{offset}/{pageSize}

### Query Parameter
This implementation uses query parameter.

    GET /books
    GET /books?offset=0&amp;limit=50
    GET /books?offset=0&amp;limit=50&amp;sortField=author&amp;sortDir=asc
    
Most proxies won't cache resources which include parameters, but there are no template parameters wasted.

### Custom Header
This implementation uses the custom header Item-Range.

    GET /books
    GET /books
    Item-Range: items=0-49
    GET /books
    Item-Range: items=0-49;author:desc

It combines the advantages of the other two implementations. A minor drawback of this solution is that the paging 
information is no longer visible in the URL.