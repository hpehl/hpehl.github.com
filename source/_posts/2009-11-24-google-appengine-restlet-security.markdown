---
layout: post
title: "Google AppEngine, Restlet & Security"
date: 2009-11-24 17:06
comments: true
categories: gae restlet guice security
---
I was wondering how to secure the resources in my current application. The application is deployed on the Google 
AppEngine and uses [Guice 2.0](https://code.google.com/p/google-guice/) and [Restlet 2.0](http://www.restlet.org). 
Inspired by the post from [David M. Chandler](http://turbomanage.wordpress.com/2009/10/07/calling-appengine-securely-from-gwt-with-gwt-dispatch/) I 
decided to use the AppEngine cookie named "ACSID" as a token in each and every url to secure my resources. This way 
the url to the "projects" resource becomes http://karaka-d8.appspot.com/rest/v1/\<ACSID\>/projects.<!-- more -->

Technically I'm using an aspect together with a custom annotation to secure the resources. Here's the Guice module for 
the security stuff:

``` java
public class SecurityModule extends AbstractModule
{
    @Override
    protected void configure()
    {
        SecurityInterceptor interceptor = new SecurityInterceptor();
        bindInterceptor(Matchers.subclassesOf(ServerResource.class), Matchers.annotatedWith(Secured.class), interceptor);
    }
}
```

With the above setup all methodes in subclasses of ServerResource which are annotated with the custom @Secured 
annotation are handled by the SecurityInterceptor. This class contains the logic to check whether there's a 
authenticated user and whether the session cookie is correct (that's essentially the code from 
[David M. Chandlers post](http://turbomanage.wordpress.com/2009/10/07/calling-appengine-securely-from-gwt-with-gwt-dispatch/))

``` java
public class SecurityInterceptor implements MethodInterceptor
{
    private static final String APPENGINE_COOKIE = "ACSID";

    @Override
    public Object invoke(MethodInvocation invocation) throws Throwable
    {
        UserService userService = UserServiceFactory.getUserService();
        User user = userService.getCurrentUser();
        if (user == null)
        {
            throw new SecurityException("No user");
        }

        ServerResource resource = (ServerResource) invocation.getThis();
        String token = (String) resource.getRequest().getAttributes().get("token");
        if (token == null || token.length() == 0)
        {
            throw new SecurityException("No security token");
        }

        // Skip check on localhost so we can test in AppEngine local dev env
        String sessionId = findSessionId(resource);
        String serverName = resource.getReference().getHostDomain();
        if (!("localhost".equals(serverName)) &amp;&amp; !(token.equals(sessionId)))
        {
            throw new SecurityException("Security token invalid");
        }

        return invocation.proceed();
    }

    private String findSessionId(ServerResource resource)
    {
        String result = null;
        Series&lt;Cookie&gt; cookies = resource.getCookies();
        for (Cookie cookie : cookies)
        {
            if (APPENGINE_COOKIE.equals(cookie.getName()))
            {
                result = cookie.getValue();
                break;
            }
        }
        return result;
    }
}
```

To make this work the resource mappings have to include a {token} parameter. So inside your Router you should have 
something like that 

``` java
attach("/{token}/projects", ProjectsResource.class);
``` 

Finally the methods you want to protect have to be annotated with the @Secured annotation:

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

    @Secured
    @Override
    protected Representation get()
    {
        Context context = new Context();
        context.set("projects", service.list());
        String xml = converter.convert("templates/projects.vm", context);
        return new StringRepresentation(xml, MediaType.TEXT_XML);
    }
}
```

One last note: First I tried to use the @Get annotation from Restlet 2.0 instead of a custom annotation and configured 
the SecurityInterceptor as follows:

``` java
bindInterceptor(Matchers.subclassesOf(ServerResource.class), Matchers.annotatedWith(Get.class), interceptor);
```
    
Unfortunately that didn't work because the @Get annotation is not available in the generated AOP proxy. So Restlet 
has no way to figure out what method to call for a GET request. Instead you have to override the get method.
