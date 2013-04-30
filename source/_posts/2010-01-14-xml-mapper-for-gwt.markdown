---
layout: post
title: "XML Mapper for GWT"
date: 2010-01-14 17:41
comments: true
categories: piriti
---
I'm a big fan of RESTful architectures. When using REST resources with XML representations in combination with GWT 
you have to parse the XML and map it to the model used in the GWT client. The code therefore is tedious and 
error-prone. So I decided to start a little framework called "piriti" (Maori for bridge). It is hosted on goolge code 
under <https://github.com/hpehl/piriti>. The basic idea behind piriti is to use annotations on your model and generate 
the parsing / mapping code with the help of deferred binding.<!-- more -->

Let's assume you have a REST resource for a book which produces the following XML representation

``` xml
<book>
    <isbn>978-0345417954</isbn>
    <pages>432</pages>
    <title>The Hotel New Hampshire</title>
    <author>
        <firstname>John</firstname>
        <surname>Irving</surname>
    </author>
    <reviews>
        <review>A hectic gaudy saga with the verve of a Marx Brothers movie.</review>
        <review>Rejoice! John Irving has written another book according to your world. You must read this book.</review>
        <review>Spellbinding, intensely human, a high-wire act of dazzling virtuosity.</review>
    </reviews>
</book>
```

On the GWT client you have the following model classes

``` java
public class Book
{
    String isbn;
    int pages;
    String title;
    Author author;
    List<String> reviews;
}

public class Author
{
    String firstname;
    String surname;
}
```

To map the XML to your model, all you have to do is annotate the relevant fields in your model and define an interface 
of type XmlReader<T>

```
public class Book
{
    interface BookReader extends XmlReader<Book> {}
    public static final BookReader XML = GWT.create(BookReader.class);

    @XmlField String isbn;
    @XmlField int pages;
    @XmlField String title;
    @XmlField Author author;
    @XmlField("reviews/review") List<String> reviews;
}

public class Author
{
    interface AuthorReader extends XmlReader<Author> {}
    public static final AuthorReader XML = GWT.create(AuthorReader.class);

    @XmlField String firstname;
    @XmlField String surname;
}
```

Now you can map the XML to your model by calling

``` java
Document document = ...; // XML representation of the book resource
Book book = Book.XML.read(document);
``` 

To learn more about piriti take a look at <https://github.com/hpehl/piriti>.