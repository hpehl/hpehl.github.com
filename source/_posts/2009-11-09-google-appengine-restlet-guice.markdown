---
layout: post
title: "Google AppEngine, Restlet & Guice"
date: 2009-11-09 13:26
comments: true
categories: gae restlet guice 
---
Currently I'm developing an application for time recording called Karaka. Karaka is deloyed on the Google AppEngine for 
Java (GAE/J) and uses inter alia the following stack:

* [Guice 2.0](http://code.google.com/p/google-guice/)
* [Restlet 2.0](http://www.restlet.org)

<!-- more -->
Basically there are two different ways to go when using the Restlet framework:

1. Run as a standalone application
2. Run in a servlet container

For the first approach there's 
a [blog entry from Tim Peierls](http://tembrel.blogspot.com/2008/07/resource-dependency-injection-in.html) on how to 
configure your resources using Guice. As Karaka is deployed on the GAE/J, I'm using the second approach. Therefore I 
created a custom servlet in combination with custom Finder and Router classes. All classes are bind together with 
Guice. This post describes my setup and shows the relevant code. Let's start by looking at the web.xml:

``` xml
<web-app xmlns="http://java.sun.com/xml/ns/javaee" version="2.5">

    <filter>
        <filter-name>guiceFilter</filter-name>
        <filter-class>com.google.inject.servlet.GuiceFilter</filter-class>
    </filter>
    <filter-mapping>
        <filter-name>guiceFilter</filter-name>
        <url-pattern>/*</url-pattern>
    </filter-mapping>

    <listener>
        <listener-class>name.pehl.karaka.server.servlet.ServletConfig</listener-class>
    </listener>

</web-app>
```

Nothing special here. The main configuration happens in the ServletConfig class:

``` java
public class ServletConfig extends GuiceServletContextListener
{
    @Override
    protected Injector getInjector()
    {
        // Further modules are omitted...
        return Guice.createInjector(new ServletModule(), new RestModule());
    }
}
```

I use two different modules: One for the servlet configuration and one for the setup of the resources. The servlet 
module registers the custom REST servlet:

``` java
public class ServletModule extends com.google.inject.servlet.ServletModule
{
    @Override
    protected void configureServlets()
    {
        serve("/rest/v1/*").with(RestletServlet.class);
    }
}
```

All REST requests are handled by the RestletServlet. The url mapping contains a version number. Using this approach 
you can later on add another servlet with a different interface / version and maintain backward compatibility. 
Now let's look at the RestletServlet:

``` java
@Singleton
public class RestletServlet extends HttpServlet
{
    @Inject
    private Injector injector;
    private Context context;
    private ServletAdapter adapter;

    @Override
    public void init() throws ServletException
    {
        context = new Context();
        Application application = new Application();
        application.setContext(context);
        application.setInboundRoot(new GuiceRouter(injector, context)
        {
            @Override
            protected void attachRoutes()
            {
                attach("/projects", ProjectsResource.class);
            }
        });
        adapter = new ServletAdapter(getServletContext());
        adapter.setTarget(application);
    }

    @Override
    protected void service(HttpServletRequest request, HttpServletResponse response) throws ServletException,
            IOException
    {
        adapter.service(request, response);
    }
}
```

The servlet is normal `HttpServlet`. The integration with the Restlet framework is not reached by inheritance but by 
using the `ServletAdapter` class. The `ServletAdapter` is configured to use a new `Context`, `Application` and our own 
`GuiceRouter`.

Another important aspect is that a reference to the Injector is provided by Guice (see "Injecting the injector" in 
the [Guice documentation](http://code.google.com/docreader/#p=google-guice&s=google-guice&t=ServletRegexKeyMapping)). 
We will need the injector later in the `GuiceFinder` class.

The `GuiceRouter` is responsible for setting up the mappings between the urls and the resources. Therefore it has 
the abstract method `attachRoutes()`. The `GuiceRouter` extends from `Router` from the Restlet framework and uses a 
`GuiceFinder` to create the resource instances:

``` java 
public abstract class GuiceRouter extends Router
{
    private final Injector injector;

    public GuiceRouter(Injector injector, Context context)
    {
        super(context);
        this.injector = injector;
        attachRoutes();
    }

    @Override
    public Finder createFinder(Class targetClass)
    {
        return new GuiceFinder(injector, getContext(), targetClass);
    }

    protected abstract void attachRoutes();

    protected Injector getInjector()
    {
        return injector;
    }
}
```

The `GuiceFinder` is the class where the resources are created. Therefore the method `create()` is overwritten. 
By calling `Injector.getInstance(targetClass)` the resource is created and all its dependencies are injected by Guice:

``` java
public class GuiceFinder extends Finder
{
    private final Injector injector;

    public GuiceFinder(Injector injector, Context context, Class targetClass)
    {
        super(context, targetClass);
        this.injector = injector;
    }

    @Override
    public ServerResource create(Class targetClass, Request request, Response response)
    {
        return injector.getInstance(targetClass);
    }
}
```

The following code shows one of the resource used in Karaka. The resource is bound to the url "/projects". So when 
the url http://server/rest/v1/projects is called a new instance of the `ProjectsResource` is created by Guice and all 
dependencies are injected.

``` java 
public class ProjectsResource extends ServerResource
{
    private final ProjectService service;
    private final TemplateConverter converter;

    @Inject
    public ProjectsResource(ProjectService service, TemplateConverter converter)
    {
        this.service = service;
        this.converter = converter;
    }

    @Get("xml")
    public Representation represent()
    {
        Context context = new Context();
        context.set("projects", service.list());
        String xml = converter.convert("templates/projects.vm", context);
        return new StringRepresentation(xml, MediaType.TEXT_XML);
    }
}
```

As you can see, there's not much code necessary to integrate the Restlet framework with the GAE/J using the servlet 
approach. Feel free to comment and let me know if this is somewhat useful.