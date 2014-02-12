---
layout: post
title: "Search using lunr.js"
date: 2014-02-11 21:44
comments: true
categories: search lunr 
---
When I [moved](/moved-blog-to-github-pages.html) my blog from Blogger to Octopress back in May 2013, I always missed a powerful and well integrated search feature. Octopress is a static site generator and has no database to be queried for searches. The default search is just a redirection to Google Custom Search. This navigates away from the blog site and comes with Google Ads.<!-- more -->
 
Once in a while I was looking for an alternative for my blog. When we developed a local search for the WildFly Admin Console, we choosed [lunr.js](http://lunrjs.com/). Lunr.js is a simple full-text search in your browser. This seems also a reasonable fit for my blog. After some research I came accross [octopress-lunr-js-search](https://github.com/yortz/octopress-lunr-js-search). It's an Octopress plugin which generates a local search index. This index is used by a handful of scripts to implement a search-as-you-type feature.
 
When implementing the search, I basically followed the [instructions](https://github.com/yortz/octopress-lunr-js-search#how-to-use) on the plugins website. However I did without the Jekyll asset plugin, because it would have meant a major reorganization of my blog. I decided to move the search to a modal dialog. This dialog is opened when you click on the little search icon in the header or press the shortcut (&#8984;+. / Ctrl+.). As you start typing, the search results will appear accordingly. 
  
Give it a try and let me know if you like it!
