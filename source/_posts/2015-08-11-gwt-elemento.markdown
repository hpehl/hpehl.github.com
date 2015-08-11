---
layout: post
title: "GWT Elemento"
date: 2015-08-11 12:32
comments: true
categories: gwt elemental
---
[GWT Elemento](https://github.com/hpehl/elemento) is a library which tries to make working with GWT [Elemental](http://www.gwtproject.org/articles/elemental.html) as easy as possible. In a nutshell Elemento brings the following features to the table:
                                                                                                                                           
- Builder like API to easily create arbitrary large element hierarchies
- HTML templates, declarative event handling and support for [handlebar](http://handlebarsjs.com/)-like expressions
- Support for dependency injection with [GIN](https://code.google.com/p/google-gin/)
- Helper methods to mix and match GWT Elemental and GWT Widgets

In this blog post I will give a short introduction to some of Element's features.<!-- more -->

# Builder API
When working with GWT Elemental it is often awkward and cumbersome to create an hierarchy of elements. Even simple structures like
```html
<section class="main">
    <input class="toggle-all" type="checkbox">
    <label for="toggle-all">Mark all as complete</label>
    <ul class="todo-list">
        <li>
            <div class="view">
                <input class="toggle" type="checkbox" checked>
                <label>Taste Elemento</label>
                <button class="destroy"></button>
            </div>
            <input class="edit">
        </li>
    </ul>
</section>
```

lead to a vast amount of `Document.createXXXElement()` and chained `Element.appendChild()` calls. However using Elemento's builder API, creating the above structure is as easy as

```java
import static org.jboss.gwt.elemento.core.InputType.checkbox;
import static org.jboss.gwt.elemento.core.InputType.text;

// @formatter:off
Element element = new Elements.Builder()
    .section().css("main")
        .input(checkbox).css("toggle-all")
        .label().attr("for", "toggle-all").innerText("Mark all as complete").end()
        .ul().css("todo-list")
            .li()
                .div().css("view")
                    .input(checkbox).css("toggle")
                    .label().innerText("Taste Elemento").end()
                    .button().css("destroy").end()
                .end()
                .input(text).css("edit")
            .end()
        .end()
    .end().build();
// @formatter:on
```

# Templates
Elemento provides an easy way to take existing HTML content and use it in your GWT application. Templates can be either HTML snippets or full HTML documents where you select an element and its children. This allows you to preview your templates more easily during design without running the application. 

Elemento leverages annotation processors to generate code which picks the HTML content from your template. Let's say you've got the following HTML document called `Todo.html`:
 
```html
<!doctype html>
<html lang="en">
<head>
    <link rel="stylesheet" href="<path-to>/node_modules/todomvc-common/base.css">
    <link rel="stylesheet" href="<path-to>/node_modules/todomvc-app-css/index.css">
</head>
<body>
<section data-element="todos" class="todoapp">
    <header class="header">
        <h1>todos</h1>
        <input data-element="newTodo" class="new-todo" placeholder="What needs to be done?" autofocus>
    </header>
    <section data-element="main" class="main">
        <input data-element="toggleAll" class="toggle-all" id="toggle-all" type="checkbox">
        <label for="toggle-all">Mark all as complete</label>
        <ul data-element="list" class="todo-list">
            <!-- Todo items are mapped to an extra template class -->
        </ul>
    </section>
    <footer data-element="footer" class="footer">
        <span data-element="count" class="todo-count"><strong>0</strong> item left</span>
        <ul class="filters">
            <li><a data-element="all" href="#/">All</a></li>
            <li><a data-element="active" href="#/active">Active</a></li>
            <li><a data-element="completed" href="#/completed">Completed</a></li>
        </ul>
        <button data-element="clearCompleted" class="clear-completed">Clear completed</button>
    </footer>
</section>
[...]
</body>
</html>
```

The HTML is enriched with `data-element` attributes. Elemento needs these attributes to select the root element and to map specific HTML elements to fields in the template class. To create a template class which maps to the `<section/>` element, create an abstract class and annotate it with `@Templated`: 

```java
@Templated("Todo.html#todos")
abstract class Todos implements IsElement {

    static Todos create() {
        return new Templated_Todos();
    }
    
    @DataElement InputElement newTodo;
    @DataElement Element main;
    @DataElement InputElement toggleAll;
    @DataElement Element list;
    @DataElement Element footer;
    @DataElement Element count;
    @DataElement("all") Element filterAll;
    @DataElement("active") Element filterActive;
    @DataElement("completed") Element filterCompleted;
    @DataElement ButtonElement clearCompleted;

    @EventHandler(element = "newTodo", on = keydown)
    void newTodo(KeyboardEvent event) {
        [...]
    }
    
    @EventHandler(element = "clearCompleted", on = click)
    void clearCompleted() {
        [...]
    }
}
```

To map specific elements from the HTML to your template class use the `@DataElement` annotation. If no value is provided for the `@DataElement` annotation, the name of the field / method is taken as default. 

It's also possible to register event handlers for elements marked with `data-element=<name>`. It does not matter whether the HTML element is mapped with `@DataElement`. Attaching the event handler will work in any case.

If you want to learn more about HTML templates take a look at the [official documentation](https://github.com/hpehl/elemento#templates). 

# Goodies
Elemento contains a small set of static helper methods to make working with elements easier. One set of methods can be used to convert between `Element` and `Widget`: 

```java
/**
 * Converts from {@link IsElement} &rarr; {@link Widget}.
 */
public static Widget asWidget(IsElement element) {...}

/**
 * Converts from {@link Element} &rarr; {@link Widget}.
 */
public static Widget asWidget(Element element) {...}

/**
 * Converts from {@link IsWidget} &rarr; {@link Element}.
 */
public static Element asElement(IsWidget widget) {...}

/**
 * Converts from {@link Widget} &rarr; {@link Element}.
 */
public static Element asElement(Widget widget) {...}

/**
 * Converts from {@link com.google.gwt.dom.client.Element} &rarr; {@link Element}.
 */
public static Element asElement(com.google.gwt.dom.client.Element element) {...}
```

Finally there are methods to iterate over the children of an element using the Java collection classes: 

```java
/**
 * Returns an iterator over the children of the given parent element. The iterator supports the {@link
 * Iterator#remove()} operation which removes the current element from its parent.
 */
public static Iterator<Element> iterator(Element parent) {...}

/**
 * Returns an iterable collection for the children of the given parent element.
 */
public static Iterable<Element> children(Element parent) {...}
```

Take a look at the [API documentation](http://rawgit.com/hpehl/elemento/site/apidocs/org/jboss/gwt/elemento/core/Elements.html) for more details.  

## Samples
Elemento comes with three different [implementations](http://hpehl.github.io/elemento/index.html) of the [TodoMVC](http://todomvc.com/) sample app. 

- Builder API: [Source](https://github.com/hpehl/elemento/tree/develop/samples/builder) | [Demo](http://hpehl.github.io/elemento/builder/index.html)
- Plain HTML templates: [Source](https://github.com/hpehl/elemento/tree/develop/samples/templated) | [Demo](http://hpehl.github.io/elemento/templated/index.html)
- HTML templates with GIN support: [Source](https://github.com/hpehl/elemento/tree/develop/samples/gin) | [Demo](http://hpehl.github.io/elemento/gin/index.html)

All three samples are using the same key to persist the todo items in the local storage. So you can switch between the samples and continue working on your tasks seamlessly ;-)
