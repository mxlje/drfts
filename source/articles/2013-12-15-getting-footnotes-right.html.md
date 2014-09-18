---
title: Getting footnotes right
subtitle: Notes about drfts, reading experience, Ruby, and my favourite markdown parser
version: 1.3

author:
  name: Max Lielje
  url: http://maxlielje.co

published: true
date: 2013-12-15 11:15 UTC 
---

When writing long form articles or essays, it’s often necessary to provide additional information to a sentence or paragraph without interrupting the reader’s flow. These annotations often represent references, thoughts, or general notes by the author, that can, but don’t have to be read in order to understand the article itself. That’s where **footnotes** come in.

I really like the concept of footnotes; especially here on drfts, where, by the nature of it being a web publication, it’s easy to add external links and references about topics that we talk about to provide interested readers with even more content to consume. 

When setting up drfts and deciding for a format that articles would be written in, I decided on Markdown.

There are countless markdown rendering engines available for nearly every language imaginable. I decided to use Redcarpet to render our markdown files and you will see why in a little bit.

## So …, footnotes?

Yeah, right. Footnotes. Redcarpet has an option to render footnotes using the PHP Markdown syntax[^1] that generates an ordered list and adds it to the bottom of the document.

[^1]: Check it out [here](http://michelf.ca/projects/php-markdown/extra/). At the time of writing this, footnotes are only available in the Redcarpet master branch on GitHub so you may need to install the gem directly from there.

While this is great (and the expected behavior) 99% of the time, it generated a user experience problem when having *multiple articles on a single page*, like the homepage for example. Because articles "don’t know about each other", the footnotes’ index starts at 1 again each time a new article is being parsed.

**This means:** Links to footnotes and back to the reference don’t necessarily jump to the correct position since there are now multiple occurrences of `<li id="fn1">` on the same page.

When the user clicks a footnote link to see the note, it can’t be guaranteed that she can use the provided link back to the position in the article, if she even got to the right note in the first place.

**The solution:** namespacing footnote IDs. By addig a unique string to the elements IDs and the reference links, users will land where they are supposed to.

## In Ruby, classes are open

In Ruby, [classes are open](https://www.ruby-lang.org/en/documentation/ruby-from-other-languages/):

> You can open them up, add to them, and change them at any time. Even core classes, like `Fixnum`or even `Object`, the parent of all objects. Ruby on Rails defines a bunch of methods for dealing with time on `Fixnum`.

In combination with Redcarpets’ API, which exposes a [bunch of different methods](https://github.com/vmg/redcarpet#and-you-can-even-cook-your-own) for customizing markdown content, this allows us to change the default output for footnotes while keeping the syntax clean and straight forward for the author.

These are my changes to the `Redcarpet::Render::HTML` class:

<script src="https://gist.github.com/mxlje/7920608.js"></script>

Let me walk you through:

By opening up the `Redcarpet::Render::HTML` class we can overwrite the default methods `footnote_ref` and `footnote_def`.

**First the reference link:** Because there is a new renderer instantiated for each article that’s being parsed and the reference is handled before the definition, we can generate an ID in here and set it to an instance variable on the renderer object itself.[^2]

[^2]: An ID is only generated if it doesn’t already exist. Otherwise there would be a different ID for each reference in the same article.

The tricky part about the definition is the **link back to the reference**. Of course, the freshly generated `@article_id` is used to namespace the element ID, but the link needs to be injected at the end of the definition. Simply appending it to `content` doesn’t work since that has already been parsed with Markdown which wraps it in `<p></p>` tags.

Therefore, the closing `</p>` needs to be replaced with the reference link and itself after that.

## Things to be aware of

**Risk of duplication**: Due to the way the ID is generated (shuffling numbers and letters), there is a risk of it spitting out duplicates, which would then render the whole thing pretty much useless. When using 4 characters however, I found that there are no duplicates when generating 1000 IDs.

That should cover us here at drfts for a pretty long time, since there probably won’t even be more than 20 or so articles on a single page at once.

**IDs change with every build**: The code that generates the ID does not use any information that is related to the article itself (eg. internal IDs or the slug) to create a fixed hash.

At the current state of drfts this isn’t a problem, though. We will see how it affects user behaviour and whether readers create external links pointing directly to a footnote, which could result in bad user experience again every time we update the article.

We are currently figuring these things out as we go along and plan on publishing more articles about technical difficulties we discover, design challenges, and everything else that comes up while building drfts.