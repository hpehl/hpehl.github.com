---
layout: post
title: "How to use Velocity to generate code in GWT"
date: 2012-01-28 21:44
comments: true
categories: piriti
---
The JSON/XML mapper [Piriti](https://github.com/hpehl/piriti) is heavily based on deferred binding and code generation.
As I started to implement code generators in Piriti I looked around how other projects deal with it and read through
the [official documentation](https://developers.google.com/web-toolkit/doc/latest/DevGuideCodingBasicsDeferred) on the
GWT site. The usual way to generate code is to extend `com.google.gwt.core.ext.Generator` and then call
`GeneratorContext.tryCreate(TreeLogger, String, String)`. The returned PrintWriter is then often wrapped into
some kind of [IndentedWriter](https://code.google.com/p/google-web-toolkit/source/browse/trunk/user/src/com/google/gwt/uibinder/rebind/IndentedWriter.java)
like the one used by GWT itself. This class adds methods to indent and unindent code and supports `printf()` like
behaviour. Finally the writer is used to generate all code. <!-- more -->This in turn results in code which looks like that:

``` java
writer.write("%s %s = null;", parameterizedValueType, value);
writer.write("List<Element> %s = filterElements(element.selectNodes(\"%s\"));",
    elements, property.getPathOrName());
writer.write("if (!%s.isEmpty()) {", elements);
writer.indent();
writer.write("%s = new %s<%s>();", value, collectionImplementation, elementType);
if (property.isConverter()) {
  // even more writer.write() statements
}
writer.write("for (Element currentElement : %s) {", elements);
writer.indent();
writer.write("%s currentValue = null;", elementType);
writer.write("XmlReader<%1$>; currentReader = xmlRegistry.getReader(%1$s.class);", elementType);
writer.write("if (currentReader != null) {");
writer.indent();
writer.write("currentValue = currentReader.read(currentElement);");
writer.outdent();
writer.write("}");
writer.write("if (currentValue != null) {");
writer.indent();
writer.write("%s.add(currentValue);", value);
writer.outdent();
writer.write("}");
writer.outdent();
writer.write("}");
writer.outdent();
writer.write("}");
```

I can't help, but this code somehow reminds me of the old times, where we generated HTML code in servlets.
This approach might work as long as the amount of generated code is small. In Piriti the code generation process
is somewhat complex and distributed over several classes. Changing the generated code became very difficult and
error-prone. Only the correct use of writer.indent() and writer.outdent() is not a trivial task. To some extent
this problem can be solved by the use of an abstract base class, which contains common code. The generated class
would extend from the abstract base class. But at the end of the day you have to generate some code in the concrete
subclass.

# Velocity to the rescue
[Velocity](http://velocity.apache.org/engine/releases/velocity-1.7/) is a Java-based template engine. It permits
anyone to use a simple yet powerful template language to reference objects defined in Java code. Velocity supports
for loops, if-then-else conditions and custom macros. Templates can include other templates. This way you can put
common code in extra templates and reuse it in other templates. Velocity is mainly used in web projects for HTML
generation. Another common use case is to generate email bodies. But there's no reason not to use Velocity for code
generation in GWT.

Doing so the above code snippet becomes something like that:

``` java
$parameterizedValueType $value = null;
List<Element> $elements = filterElements(element.selectNodes("$property.pathOrName"));
if (!${elements}.isEmpty()) {
    $value = new $collectionImplementation&lt;$elementType&gt;();
    #if ($property.converter) #createConverter() #end
        for (Element currentElement : $elements) {
        $elementType currentValue = null;
        XmlReader<$elementType> currentReader = xmlRegistry.getReader(${elementType}.class);
        if (currentReader != null) {
            currentValue = currentReader.read(currentElement);
        }
        if (currentValue != null) {
            ${value}.add(currentValue);
        }
    }
}
```

If you compare the two code snippets you get the idea! The velocity based code is much more readable. As you can see
the velocity template contains variable references like $elements. Before the template is rendered all necessary
variables must be put into the so-called Velocity context which is more or less a big map. If the variable refers to
a java object you can use its properties and even call methods.

To use Velocity for code generation you have to setup the Velocity engine, create the Velocity context and merge the
template. In Piriti the engine is configured with the following properties:

```
velocimacro.library = name/pehl/piriti/rebind/propertyMacros.vm
runtime.log.logsystem.class = name.pehl.piriti.rebind.VelocityLogger
input.encoding = UTF-8
output.encoding = UTF-8
resource.manager.logwhenfound = true
resource.manager.defaultcache.size = 0
resource.loader = cp
cp.resource.loader.class = org.apache.velocity.runtime.resource.loader.ClasspathResourceLoader
cp.resource.loader.cache = false
```

Finally the code generation process is reduced to the following lines:

``` java
PrintWriter printWriter = generatorContext.tryCreate(treeLogger, somePackage, implName);
if (printWriter != null)
{
    VelocityContext context = new VelocityContext();
    // Put all neccesarry objects into the velocity context
    context.put("foo", ...);

    InputStream inputStream = this.getClass().getClassLoader().getResourceAsStream(
        "name/pehl/piriti/rebind/velocity.properties");
    Properties properties = new Properties();
    properties.load(inputStream);
    VelocityEngine velocityEngine = new VelocityEngine(properties);
    velocityEngine.mergeTemplate("someTemplate.vm", "UTF-8", context, printWriter);
    generatorContext.commit(treeLogger, printWriter);
}
```

If you want to delve deeper into the code generation process in [Piriti](https://github.com/hpehl/piriti), check out
the trunk and take a look into the code.
