# GambitReact

## What is GambitReact?

GambitReact is a **reactive web app framework** for **Gambit Scheme**, a bit
like React, Angular, Next.js, and other frameworks. It provides an intuitive
abstraction for manipulating reactive variables. It also offers an easy way to
insert those variables into HTML elements. This enables you to write web pages
in an almost declarative style!

All of this, written in Scheme, **under 1000LOC (reactivity + HTML intergration)**.

## An overview of reactivity

The library `lib/reactive` lets us create reactive variables. First, let's look
at a few simple examples:

### Example 1

```scheme
> (define x (reactive-var 0))
> (reactive-update! x 42)
> (display (reactive-ref x)) ;; displays 42
42
```

This program simply displays the value `42`, which is stored in the reactive variable.

### Example 2

```scheme
> (define x (reactive-var 42))
> (define y (reactive (+ 1 (reactive-ref x))))
> (reactive (println "!!! y = " (reactive-ref y)))
<reactive-block #1 ...>
> (reactive-update! x 44)
!!! x = 43
> (reactive-update! x 45)
!!! x = 44
```

This program displays `"!!! y = 44"` and `"!!! y = 45"` when we modify the value stored in the reactive variable.

### What just happened?

A reactive variable is like a box containing a value that can be accessed with
`reactive-ref` and modified with `reactive-set!`. In the second example, the
value of `y` is reactively set according to `x+1`, meaning that when `x`
changes, we update `y`. The second reactive statement showcases a little of
the inner workings of the reactive statement by displaying the value of `y` when
`x` changes. In other words, the reactive block `(reactive (println "!!! x = "
(reactive-ref x)))` *binds* the display of `x` to its value.

## HTML-like syntax

The library `lib/reactive-html` lets us create HTML elements that *can* be reactive. Here is an example without any reactivity:

```scheme
(createApp
  (<div>
    (<p> "I love Gambit !")))
```

This simply creates the following tags:

```html
<div>
    <p>I love Gambit!</p>
</div>
```

Here, `createApp` is the entry point for our web app. It takes any number of arguments and injects them into our web page. See `demo/` for more examples.

### Attributes

#### Classic attributes

If you want to include attributes in the HTML syntax, simply use the attribute name as a keyword, followed by its value. For example:

```scheme
(createApp
   (<div>
     style: "color: red;"
     class: "myclass"
     (<p>
       data-my-custon-attribute: "my attribute value"
       "I love Gambit !")))
```

This would create the following HTML structure:

```html
<div style="color: red;" class="myclass">
      <p data-my-custom-attribute="my attribute value">
      I love Gambit !
    </p>
</div>
```

#### Special attributes

We can also easily add event handlers. For example, if we want to do something when we click a button, we can write:

```scheme
(createApp
   (<div>
    (<button>
      on:click: (lambda (e) \console.log("button clicked !"))
      "My button")))
```

This creates a button that, when clicked, prints `"button clicked !"` to the console.

The `on:event:` special keyword is not limited to the `"click"` event. It adds a new callback for the specified event using `addEventListener`. This is equivalent to adding the following line of JavaScript: `myButton.addEventListener('event', myCallback)`.

## Combining HTML and reactivity

Each HTML tag we saw earlier can accept other HTML elements or a *reactive variable*. Let's look at an example:

```scheme
(createApp

 (let ((my-var (reactive-var 0)))
  (<div>
   (<button> "Number of clicks : " my-var)))

)
```

Here, we have a button containing the text `"Number of clicks : 0"`. Clicking the button does nothing because we haven't added a callback yet. Let's do that in the next example:

```scheme
(createApp

 (let ((my-var (reactive-var 0)))
  (<div>
   (<button>
    on:click: (lambda (e) (reactive-set! (+ 1 (reactive-ref x))))
    "Number of clicks : " my-var)))

)
```

This version now works! The button updates the number of clicks accordingly. We also have a very declarative way of expressing our web interface.

## I want more demos!

If you want to see demos, check out the [demos](./demo)! There is a demo using
a reactive web socket abstraction (the chat) and more examples on how to use
the library. To run them, read below.

## How does this work?

You can check the implementation, under 1000 LOC, fully in scheme in the folder [lib](./lib).

## Run demos

To run a demo, [install gambit](https://gambitscheme.org), then use:

```sh
make demo/[my demo]
```

You can also run demos in "update mode", which automatically reloads the page
when the dependencies used to generate the demo change. Note that this requires
`python3` to be installed and available inside your `PATH`. To do so, use:

```sh
make SERVE=update demo/[my demo]
```

To run the chat demo, you must also start the socket server (requiring `node.js`):

```sh
make websocket-server
make demo/chat
```

This setup has only been tested in Unix environments.

# Questions, comments, suggestions, problems?

If you have questions, comments, suggestions or problems, write an issue on
GitHub or [contact me](https://oestoleary.com). Note that this library is more
of an experiment of combining reactivity and Scheme and should probably not be
used in production.
