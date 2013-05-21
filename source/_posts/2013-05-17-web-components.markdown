---
layout: web_components
title: "Web Components"
date: 2013-05-17 12:57
comments: true
categories: web
---
I recently watched [Eric Bidelmans](https://plus.google.com/+EricBidelman/) [presentation](http://www.youtube.com/watch?v=fqULJBBEVQE) on
Web Components at Google IO 13. [Web Components](https://dvcs.w3.org/hg/webcomponents/raw-file/tip/explainer/index.html) 
is an effort to bring true modularisation to web development. For the first time you'll have encapsulation at the 
browser level. No more mess with duplicate IDs or mixed CSS style rules. <!-- more -->The building blocks of Web 
Components are

- [Shadow DOM](https://dvcs.w3.org/hg/webcomponents/raw-file/tip/spec/shadow/index.html)
- [Templates](https://dvcs.w3.org/hg/webcomponents/raw-file/tip/spec/templates/index.html)
- [Custom Elements](https://dvcs.w3.org/hg/webcomponents/raw-file/tip/spec/custom/index.html)
- [HTML Imports](https://dvcs.w3.org/hg/webcomponents/raw-file/tip/spec/imports/index.html)

If you think this is a long way of and available in a few years, then you're complete wrong! You can use Web Components 
today. And they are already used by the browser vendors under the hood. 
This [article](http://glazkov.com/2011/01/14/what-the-heck-is-shadow-dom/) from 
[Dimitri Glazkov](http://glazkov.com/about/) opened my eyes. Many of the new HTML5 elements like 
`<input type="range"/>`, `<input type="date"/>` or `<video/>` are implemented using Web Compontents. You can see the 
markup behind those elements if you enable Shadow DOM in Chrome Canary. The screenshot below shows the internal markup 
of an `<input type="date"/>` element:

{% img centered /images/posts/input_type_date_shadow_dom.png %}


# V-Card Sample
If you want to start creating your own Web Components, take a look at [Polymer](http://www.polymer-project.org/). It's 
a framework for developing Web Components today. It fills out missing browser implementation with so called polyfills. 

Let's build our own Web Component using Polymer. We'll create a custom element named `v-card` which renders a business 
card:

```html
<!DOCTYPE html>
<html>
<head>
    <script src="polymer.js"></script>
    <link rel="import" href="v-card.html">
</head>
<body>
<v-card>
    <span class="fn">Harald Pehl</span>
    <span class="position">Senior Software Engineer</span>
    <a class="url" href="http://hpehl.info">http://hpehl.info</a>
    <a class="twitter" href="https://twitter.com/haraldpehl">@haraldpehl</a>
    <a class="gplus" href="https://plus.google.com/u/0/112941298216109713269/">+Harald Pehl</a>
    <img class="logo" src="http://upload.wikimedia.org/wikipedia/it/archive/c/cb/20120516124751!Red_hat_logo.png">
</v-card>
</body>
</html>
```

The actual Web Component is implemented in `v-card.html`. Using the `<content>` element and CSS selectors we can pull
in content from the host page. 

```html
<element name="v-card">
    <template>
        <style>
            ...
        </style>
        <section>
            <header>
                <h1><content select="span.fn"></content></h1>
                <h2><content select="span.position"></content></h2>
            </header>
            <ol>
                <li>
                    <content select="a.url"></content>
                </li>
                <li>
                    <content select="a.twitter"></content>
                </li>
                <li>
                    <content select="a.gplus"></content>
                </li>
            </ol>
            <div class="logo">
                <content select="img.logo"></content>
            </div>
        </section>
    </template>
    <script>
        Polymer.register(this);
    </script>
</element>
```

Here is the result of our first Web Component. Please note that I'm unsing the flexbox model for rendering the 
business card. Support for flexbox is somewhat [limited](http://caniuse.com/#feat=flexbox). Safari does not support it 
at the moment. If you're using Firefox you might have to enable `layout.css.flexbox.enabled` in about:config. 