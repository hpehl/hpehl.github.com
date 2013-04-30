---
layout: post
title: "JSON Mapping in Piriti"
date: 2010-03-22 12:11
comments: true
categories: piriti
---
Following a [proposal](http://restlet.tigris.org/ds/viewMessage.do?dsForumId=4447&dsMessageId=2450017) by Jerome 
Louvel, I added JSON mapping to Piriti. Piriti is a JSON / XML mapper for GWT based on annotations and deferred 
binding.<!-- more -->

To map JSON data you have to annotate your model classes with @JsonField annotations. In case you have the following 
JSON structure:

``` json
{
    isbn: "978-0345417954", 
    pages: 432,
    title: "The Hotel New Hampshire",
    author: {
        firstname: "John",
        surname: "Irving", 
    },
    reviews: [
        "A hectic gaudy saga with the verve of a Marx Brothers movie.", 
        "Rejoice! John Irving has written another book according to your world.", 
        "Spellbinding, intensely human, a high-wire act of dazzling virtuosity."
    ]
}    
```

You can use the following code to map the JSON data to your model:

``` java
public class Book
{
    interface BookReader extends JsonReader&lt;Book&gt; {}
    public static final BookReader JSON = GWT.create(BookReader.class);

    @JsonField String isbn;
    @JsonField int pages;
    @JsonField String title;
    @JsonField Author author;
    @JsonField List&lt;String&gt; reviews;
}

...

public class Author
{
    interface AuthorReader extends JsonReader&lt;Author&gt; {}
    public static final AuthorReader JSON = GWT.create(AuthorReader.class);

    @JsonField String firstname;
    @JsonField String surname;
}

...

String jsonString = ...; // The JSON structure (see above) 
Book book = Book.JSON.read(jsonString);
```

To learn more about piriti take a look at <https://github.com/hpehl/piriti>.