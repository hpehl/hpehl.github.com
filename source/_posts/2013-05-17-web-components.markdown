---
layout: post
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

If you think this is a long way of and available in a few years, then you're completely wrong! You can use Web Components 
today. And they are already used by the browser vendors under the hood. 
This [article](http://glazkov.com/2011/01/14/what-the-heck-is-shadow-dom/) from 
[Dimitri Glazkov](http://glazkov.com/about/) opened my eyes. Many of the new HTML5 elements like 
`<input type="range"/>`, `<input type="date"/>` or `<video/>` are implemented using Web Compontents. You can see the 
markup behind those elements if you enable Shadow DOM in Chrome Canary. The screenshot below shows the internal markup 
of an `<input type="date"/>` element:

{% img centered /images/posts/input_type_date_shadow_dom.png %}


# V-Card Sample
If you want to start creating your own Web Components, I strongly recommend to take a look at 
[Polymer](http://www.polymer-project.org/). It's a framework for developing Web Components today. It fills out missing 
browser implementation with so called polyfills. 

Let's jump into Web Component development and build a `v-card` element which renders a business card. The following 
code shows the host page containing the custom `v-card` element. It expects a fullname, a title, several 
links and a logo. The parameters are wrapped in regular HTML elements. The class names are taken from the 
[hCard microformat](http://microformats.org/wiki/hcard) and are used later to select the relevant information.

```html
<!DOCTYPE html>
<html>
<head>
    <script src="/path/to/polymer.js"></script>
    <link rel="import" href="v-card.html">
</head>
<body>
<v-card>
    <span class="fn">Harald Pehl</span>
    <span class="position">Senior Software Engineer</span>
    <a class="url" href="http://hpehl.info">http://hpehl.info</a>
    <a class="twitter" href="https://twitter.com/haraldpehl">@haraldpehl</a>
    <a class="gplus" href="https://plus.google.com/u/0/112941298216109713269/">+Harald Pehl</a>
    <img class="logo" src="http://upload.wikimedia.org/wikipedia/it/archive/c/cb/20120516124751!Red_hat_logo.png"/>
</v-card>
</body>
</html>
```

The `v-card` implementation uses its own CSS styles and markup. Thanks to Shadow DOM they don't conflict with the 
host page. The data for the business card is pulled from the host page using the `<content>` element and CSS selectors. 
Finally the call to `Polymer.register(this)` takes care of all the polyfill magic to make this work accross all 
modern browsers. 

```html
<element name="v-card">
    <template>
        <style>
            header, h1, h2, ol, li, img {
                margin: 0;
                padding: 0;
            }
            
            section {
                background: #fff;
                border-radius: 5px;
                box-shadow: 0 0 4px 2px rgba(0, 0, 0, .5);
                width: 30rem; height: 15rem;
                display: flex; align-items: center; justify-content: space-between;
            }
            
            header {
                background-color: #555;
                color: white;
                text-align: right;
                padding: 1rem 1rem 1rem 2.5rem;
            }
            
            h1, h2 { font-weight: normal; }
            header h1 { font-size: 1.5rem; }
            header h2 { font-size: 1rem; }
            
            ol { font-size: .8rem; }
            li { list-style: none; }
            
            .logo_container { margin-right: 1rem; }
        </style>
        <section>
            <header>
                <h1><content select="span.fn"></content></h1>
                <h2><content select="span.position"></content></h2>
            </header>
            <ol>
                <li><content select="a.url"></content></li>
                <li><content select="a.twitter"></content></li>
                <li><content select="a.gplus"></content></li>
            </ol>
            <div class="logo_container">
                <content select="img.logo"></content>
            </div>
        </section>
    </template>
    <script>
        Polymer.register(this);
    </script>
</element>
```

Below you can see the `v-card` Web Component in action. Please note that I'm unsing CSS3 flexbox to render the 
business card. Support for flexbox is somewhat [limited](http://caniuse.com/#feat=flexbox). Chrome should make 
no problems, for Firefox you might have to enable `layout.css.flexbox.enabled` in about:config. All other browsers 
will most likely have problems rendering the business card. If that's the case here's a 
[reference representation]({{ root_url }}/images/posts/v-card_reference.png).

{% include post/v_card.html %}

I hope this simple example shows the potential behind Web Components. I'm convinced Web Components are the future of 
client side web development. If you want to dive deeper into the subject here is a list of useful resources:

- [Web Components in Action](http://www.youtube.com/watch?v=0g0oOOT86NY): Google IO session about Polymer 
- [X-Tags](http://www.x-tags.org/): Polymer counterpart from Mozilla 
- [Web UI](http://www.dartlang.org/articles/web-ui/): Darts implementation for Web Components
- Shadow DOM series on HTML5 Rocks:
    - [Shadow DOM 101](http://www.html5rocks.com/en/tutorials/webcomponents/shadowdom/)
    - [Shadow DOM 201](http://www.html5rocks.com/en/tutorials/webcomponents/shadowdom-201/): CSS and Styling
    - [Shadow DOM 301](http://www.html5rocks.com/en/tutorials/webcomponents/shadowdom-301/): Advanced Concepts & DOM APIs
- [Shadow DOM Visualizer](http://html5-demos.appspot.com/static/shadowdom-visualizer/index.html)
