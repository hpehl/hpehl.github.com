---
layout: post
title: "Announcement: Piriti 0.7.0b1"
date: 2011-05-09 23:12
comments: true
categories: piriti
---
I'm pleased to announce the first beta of the upcoming Piriti 0.7.0 release. Piriti 0.7.0 is a major release with 
breaking API changes, lots of new features and bugfixes.<!-- more -->

### Breaking API Changes

* Piriti requires GWT 2.2 and GIN 1.5
* Dropped GXT support
* Removed `@Json`, `@JsonMappings`, `@Xml` and `@XmlMappings` annotations

### New Features

* Devided Piriti into different modules:
  * `name.pehl.piriti.commons.Commons`
  * `name.pehl.piriti.converter.Converter`
  * `name.pehl.piriti.json.JSON`
  * `name.pehl.piriti.property.Property`
  * `name.pehl.piriti.xml.XML`
* Simplified mapping setup: All properties in a POJO hirarchy are now mapped by default
* Added new annotations to overide default behaviour:
  * `@Order`
  * `@Path`
  * `@Format`
  * `@Native`
  * `@Transient`
  * `@CreateWith`
  * `@MapUpTo`
* Added `@Mappings` and `@Mapping` annotation for external mappings (JSON and XML)
* Added support for polymorhic assoziations
* Converters can now be used for any type
* Added XML serialisation (not yet implemented, but scheduled for the 0.7.0 release)
* Added support for IDs and IDREFs in JSON (not yet implemented, but scheduled for the 0.7.0 release)

### Bugfixes

* Fixed problems when mapping collection implementations
* `GWT.create()` is now used instead of new operator
* I also restructured the wiki and added a FAQ and a comparison to other JSON / XML mappers. Feel free to visit 
<https://github.com/hpehl/piriti/> and test the new release.