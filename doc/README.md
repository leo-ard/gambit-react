# Starting point

**NOTE : The name will change shortly from GambitReact to something more *flashy !***

**WARNING: This doc is under development. Anything can change at any time without warning**

##  What is GambitReact
GambitReact is a **reactive web app framework** for **gambit scheme**, a bit like React, Angular, Next.js, and other frameworks. It provides an intuitive abstraction to manipulate reactive variables. On top of this, it includes an easy way to insert those variables inside html elements. This empowers you to write web pages with an almost declarative style !  

## An overview of reactivity
The library `lib/reactive` lets us write reactive variables. First, let's see a few simple examples : 

### example 1

```scheme
> (define x (reactive-var 0))
> (reactive-set! x 42) 
> (display (reactive-ref x)) ;; displays 42
42
```

This program will simply show the value `42` that is present inside the reactive var.

### example 2

```scheme
> (define x (reactive-var 42))
> (reactive (pp (list 'x= (reactive-ref x))))
<reactive-block #1 ...>
> (reactive-set! x 43)
(x= 43)
> (reactive-set! x 44)
(x= 44)
```

This program display 43 and 44 when we modify the value inside the reactive var!

### What just happened

The first example is pretty straight forward. A reactive var contains a value, and it can be accessed with `reactive-ref` and modified with `reactive-set!`. The second example is more interesting. Here we see that the value inside the reactive variable `x`  is displayed each time it changes. In other words, `(pp (list 'x= (reactive-ref x)))` is called each time the value of `x` is changed. This is what the `reactive` keyword does. It creates a `reactive-block` that *activates* each time `x` is changed with `reactive-set!`.

## HTML-like syntax

The library `lib/reactive-html` lets us write HTML elements that *can* be reactive. We will see reactivity on the 3rd chapiter. Here is an example without any reactivity :

```scheme
(createApp
  (<div>
    (<p> "I love Gambit !")))
```

This will simply create the tags : 

```html
<div> 
	<p>I love Gambit!</p>
</div>
```

Here createApp is only the entry point for our web app. It takes any number of arguments and injects them into our webpage. See `demo/` for more info.

### Attributes
#### Classic attributes

If you want to include attributes in the HTML syntax, simply use the attribute name as a keyword with its value. For example : 
```scheme
(createApp
   (<div> 
	 style: "color: red;"
	 class: "myclass"
	 (<p>
	   data-my-custon-attribute: "my attribute value"
	   "I love Gambit !")))
```

This would create this html structure : 

```html
<div style="color: red;" class="myclass">
  	<p data-my-custom-attribute="my attribute value">
	  I love Gambit !
	</p>
</div>
```

#### Special attributes
We can also easily create events. For example, if we want to do something when we click a button, we can do : 

```scheme
(createApp
   (<div> 
	(<button>
	  on:click: (lambda (e) \console.log("button clicked !"))
	  "My button")))
```
This will create a button that, when pressed, prints "button clicked !" in the console. 

The `on:event:` special keyword is not limited to the "click" event. It only adds a new callback on the event `event` with `addEventListener`. It can be seen as adding this line of javascript : `myButton.addEventListener('event', myCallback)`.

## Combining HTML and reactivity

Each HTML tag that we saw earlier can either take another HTML elements, or a *reactive variable*. Let's see an example :

```scheme
(createApp
 
 (let ((my-var (reactive-var 0)))
  (<div>
   (<button> "Number of clicks : " my-var)))
 
)
```

Here, we can see that we have a button, containing the text `"Number of clicks : 0"`.  We can see that clicking the button does nothing, we didn't add the callback yet. Let's do this in the next example :

```scheme

(createApp
 
 (let ((my-var (reactive-var 0)))
  (<div>
   (<button> 
	on:click: (lambda (e) (reactive-set! (+ 1 (reactive-ref x))))
	"Number of clicks : " my-var)))

)
```

This version now works! We can see that we have a button that updates the number of clicks accordingly. We also see that we have a very "declarative" way of expressing our interface. 

## See more
If you want to see more, you can go check out the [demos](../demo) !
