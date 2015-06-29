---
layout: post
title: "Extending HAL Management Console"
date: 2015-06-26 14:49
comments: true
categories: console jboss hal extension
---
The HAL management console provides the UI to configure almost any subsystem in WildFly. However for subsystems provided by 3rd party projects like [PicketLink](http://picketlink.org/), [Teiid](http://teiid.jboss.org/) or [Keycloak](http://keycloak.jboss.org/) there's no way to configure the management resources. This is where the HAL extensions come into play. They provide an easy way to extend the console and provide a frontend to configure the related subsystem. This blog post will walk through the process from creating an extension to including it in the HAL release stream.<!-- more -->

# Background

Before we start let me give you some technical background. The HAL management console is a GWT web application. It uses a maven build and depends mainly on [GIN](https://code.google.com/p/google-gin/) for dependency injection and [GWTP](http://dev.arcbees.com/gwtp/) for MVP. Extensions need to use the same stack and must create a maven artifact which is used by the [HAL release stream](https://github.com/hal/release-stream) at *compile time*. As a result the final management console is produced. This means that the final console might contain many extensions. However the extensions will only show up if the relevant subsystem is part of WildFly. Furthermore since the console uses [code splitting](http://www.gwtproject.org/doc/latest/DevGuideCodeSplitting.html) the extension's bits & pieces will only be loaded on demand. 
 
# Get Started

As of today extensions need to be developed against HAL 2.8.0 or greater. This in turn requires WildFly 10.x as target platform. To get started quickly we provide a [maven archetype](https://github.com/hal/archetypes/tree/master/subsystem-extension). The archetype creates an extension with a presenter / view tuple to edit the top level attributes of a given subsystem. 

Besides the regular maven coordinates like `groupId`, `artifactId` et al the archetypes uses the following parameters:

- `extensionName`: The name / title of the extension as it appears in the UI. Should be a human friendly term which can contains spaces. 
- `gwtModule` The name of the GWT module w/o the `.gwt.xml` suffix. Must not contain whitespace. 
- `subsystem`: The name of the subsystem. The extension will only show up in the UI if the subsystem is configured in standalone mode or is part of the selected profile in domain mode. 
- `nameToken`: An unique name token used to identify the extension's page in the UI. Should be an all lowercase string separated with dashes. Defaults to the subsystem name. See the [GWTP documentation](http://dev.arcbees.com/gwtp/features/PlaceManager.html) for more infos about place management.
 
The archetype is deployed to the [JBoss Maven Repository](https://repository.jboss.org/nexus/index.html#welcome). In order to use it, make sure to specify the catalog flag `-DarchetypeCatalog=https://repository.jboss.org`. 

## Request Controller

Let's say we want to develop an extension for the subsystem `request-controller`. This subsystem is used for request limiting and graceful shutdown and is currently not covered in the HAL management console. Open a shell and execute   

```
mvn archetype:generate \
    -DarchetypeCatalog=https://repository.jboss.org \
    -DarchetypeGroupId=org.jboss.hal.archetypes \
    -DarchetypeArtifactId=hal-subsystem-extension-archetype
```

After providing all required parameters you should end up with a new maven project which consists of two sub modules:

- `gui`: Contains the GWT code for the extension
- `app`: Provides a GWT module to run and test the extension

Before we dive into the details, here's a preview of what the extension is going to look like in the navigation, read-only and edit mode: 

{% img centered /images/posts/extension_1.png "Navigation" %}
{% img centered /images/posts/extension_2.png "Read-only mode" %}
{% img centered /images/posts/extension_3.png "Edit mode" %}

# Develop

The development of the extension happens in the `gui` module. The archetype creates all necessary building blocks:

- a presenter / view tuple
- the GIN / GWTP mixins
- i18n helper classes

## Presenter / View Tuple

The GWTP presenter includes the proxy interface which carries the `@SubsystemExtension` annotation. This annotation marks the enclosing presenter as an extension. The view interface defines a method to update the view with the subsystem data. Finally there are two methods to load and save the subsystem attributes. 

```java 
public class ExtensionPresenter
        extends Presenter<ExtensionPresenter.MyView, ExtensionPresenter.MyProxy> {

    public final static String ROOT_RESOURCE = "{selected.profile}/subsystem=request-controller";
    public final static AddressTemplate ROOT_RESOURCE_ADDRESS = AddressTemplate.of(ROOT_RESOURCE);


    @ProxyCodeSplit
    @NameToken("request-controller")
    @RequiredResources(resources = ROOT_RESOURCE)
    @SearchIndex(keywords = {"request-controller"})
    @SubsystemExtension(name = "Request Controller", group = "Extensions", key = "request-controller")
    public interface MyProxy extends ProxyPlace<ExtensionPresenter> {}


    public interface MyView extends View, HasPresenter<ExtensionPresenter> {
        void update(ModelNode data);
    }
    
    
    private final StatementContext statementContext;
    private final DispatchAsync dispatcher;
    private final CrudOperationDelegate operationDelegate;
    private final I18n i18n;

    @Inject
    public ExtensionPresenter(final EventBus eventBus, final MyView view, final MyProxy proxy,
            final StatementContext statementContext, final DispatchAsync dispatcher, final I18n i18n) {
        super(eventBus, view, proxy, MainLayoutPresenter.TYPE_MainContent);
        this.statementContext = statementContext;
        this.dispatcher = dispatcher;
        this.i18n = i18n;
        this.operationDelegate = new CrudOperationDelegate(statementContext, dispatcher);
    }
      
    [...]
    
    private void loadSubsystem() {
        Operation operation = new Operation.Builder(READ_RESOURCE_OPERATION,
                ROOT_RESOURCE_ADDRESS.resolve(statementContext)).build();
        dispatcher.execute(new DMRAction(operation), new SimpleCallback<DMRResponse>() {
            @Override
            public void onSuccess(final DMRResponse response) {
                ModelNode body = response.get();
                if (body.isFailure()) {
                    Console.error(i18n.extensionConstants().load_failed(), body.getFailureDescription());
                } else {
                    getView().update(body.get(RESULT));
                }
            }
        });
    }

    public void onSaveResource(final Map<String, Object> changedValues) {
        operationDelegate.onSaveResource(ROOT_RESOURCE_ADDRESS, null, changedValues,
                new CrudOperationDelegate.Callback() {
                    @Override
                    public void onFailure(final AddressTemplate addressTemplate, final String name, final Throwable t) {
                        Console.error(i18n.consoleMessages().modificationFailed("subsystem 'request-controller'"),
                                t.getMessage());
                    }

                    @Override
                    public void onSuccess(final AddressTemplate addressTemplate, final String name) {
                        Console.info(i18n.consoleMessages().modified("subsystem 'request-controller'"));
                        loadSubsystem();
                    }
                });
    }
}
```

The view creates a form based on the subsystem metadata. When the user clicks save, control is delegated to the presenter which executes the relevant DMR operations to store the updated attributes in the management model. 

```java
public class ExtensionView extends SuspendableViewImpl implements ExtensionPresenter.MyView {

    private final ResourceDescriptionRegistry descriptionRegistry;
    private final SecurityFramework securityFramework;

    private ExtensionPresenter presenter;
    private ModelNodeForm form;

    @Inject
    public ExtensionView(final ResourceDescriptionRegistry descriptionRegistry,
            final SecurityFramework securityFramework) {
        this.securityFramework = securityFramework;
        this.descriptionRegistry = descriptionRegistry;
    }

    @Override
    public Widget createWidget() {
        SecurityContext securityContext = securityFramework.getSecurityContext(presenter.getProxy().getNameToken());
        ResourceDescription resourceDescription = descriptionRegistry.lookup(
                ExtensionPresenter.ROOT_RESOURCE_ADDRESS);

        ModelNodeFormBuilder.FormAssets formAssets = new ModelNodeFormBuilder()
                .setConfigOnly()
                .setResourceDescription(resourceDescription)
                .setSecurityContext(securityContext)
                .build();

        form = formAssets.getForm();
        form.setToolsCallback(new FormCallback() {
            @Override
            public void onSave(Map changedValues) {
                presenter.onSaveResource(changedValues);
            }

            @Override
            public void onCancel(Object entity) {
                form.cancel();
            }
        });

        return new SimpleLayout()
                .setPlain(true)
                .setHeadline("Request Controller")
                .setDescription(SafeHtmlUtils.fromString(resourceDescription.get(DESCRIPTION).asString()))
                .addContent("Attributes", formAssets.asWidget())
                .build();
    }

    [...]

    @Override
    public void update(final ModelNode data) {
        form.edit(data);
    }
}
```

## GIN / GWTP Mixins

These mixins are needed to extend the dependency injection scope and wire up the presenter / view tuples. A mixin is declared both as a binding and model extension. The `@GinExtension` value refers the GWT module descriptor used with the extension.

The injection points:

```java
@GinExtension
public interface Extension {
    AsyncProvider<ExtensionPresenter> getExtensionPresenter();
}
```

The actual binding:

```java
@GinExtensionBinding
public class ExtensionBinding extends AbstractPresenterModule {

    @Override
    protected void configure() {
        bindPresenter(ExtensionPresenter.class,
                ExtensionPresenter.MyView.class,
                ExtensionView.class,
                ExtensionPresenter.MyProxy.class);
    }
}
```

## Helper Classes

Finally the archetype creates some helper classes to deal with i18n constants and messages. It provides both access to HAL's constants and messages and to the resources defined by the extension:

```java
public class I18n {

    private final UIConstants consoleConstants;
    private final UIMessages consoleMessages;
    private final ExtensionConstants extensionConstants;
    private final ExtensionMessages extensionMessages;

    @Inject
    public I18n(final UIConstants consoleConstants, final UIMessages consoleMessages,
            final ExtensionConstants extensionConstants, final ExtensionMessages extensionMessages) {
        this.consoleConstants = consoleConstants;
        this.consoleMessages = consoleMessages;
        this.extensionConstants = extensionConstants;
        this.extensionMessages = extensionMessages;
    }

    public UIConstants consoleConstants() {
        return consoleConstants;
    }

    public UIMessages consoleMessages() {
        return consoleMessages;
    }

    public ExtensionConstants extensionConstants() {
        return extensionConstants;
    }

    public ExtensionMessages extensionMessages() {
        return extensionMessages;
    }
}
```
 
# Run

To launch the extension, switch to the `app` directory and execute one of the following:
 
- `mvn gwt:run` for GWT SuperDevMode
- `mvn gwt:run|debug -Dgwt.superDevMode=false` to use the old DevMode. Please note that you'll need [Firefox <= 26](http://ftp.mozilla.org/pub/mozilla.org/firefox/releases/26.0/) and the [GWT plugin](http://www.gwtproject.org/missing-plugin/) to use DevMode.

You'll need a running WildFly instance which is configured to allow access from http://localhost:8888. Use one of the following CLI commands to configure the management endpoint:

- standalone mode: 

        /core-service=management/management-interface=http-interface:list-add(name=allowed-origins,value=http://localhost:8888)
        reload
    
- domain mode:

        /host=master/core-service=management/management-interface=http-interface:list-add(name=allowed-origins,value=http://localhost:8888)
        reload --host=master

Please note that the extension will only show up in the UI if the subsystem is configured in standalone mode or is part of the selected profile in domain mode. 

# Include 

The [HAL release stream](https://github.com/hal/release-stream) is a maven build which combines different extensions at *compile time* and generates a final management console. You can clone its repository to test the build with your extension. Please contact us if you want to include your extension into the release stream. 

# Resources
  
Most of the topics in this blog post are also covered in the [official HAL documentation](http://hal.gitbooks.io/dev/content/). See the section [Building Blocks / Extensions](http://hal.gitbooks.io/dev/content/building-blocks/extensions.html) for more details.

# It's your turn

Now if you want to write your own extension, great - go ahead! If you have any questions or comments, please do not hesitate to [contact](http://hal.gitbooks.io/dev/content/community/index.html) us.
