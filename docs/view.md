---
title: View
heading: Lanes.Data.View
---

Lanes provides a Lanes.Views.Base class that all other views extend from.

In their simplest form, a view simply renders a string into a DOM element. They provide a mediating interface between data and the DOM.

Since both Models, Collections, and the DOM emit events, a view's job is to listen to the events and then manipulate the other parties data structures.

Lanes' base view provides numerous hooks and helper functions to make the process of responding to events and relaying them easier.

Views can also be nested inside other views and will bubble relevant events up to thier parent views.

Views inherit from [Ampersand State](http://ampersandjs.com/docs#ampersand-state), and therefore support all the same methods and declarations that it does.

<aside>
Unlike Backbone.js, when the view is rendered the old el (if present)
is discared and an new one is created at the same point in the DOM.
This prevents the doubly nested divs issue that Backbone experiences,
but can be suprising behaviour for those who aren't expecting it.
</aside>

### API Reference

# initialize

`new View({options})`

Called by the constructor after the view is initialized.  initialize can be used by your views for performing initialization of the class.

Views have several options that will be copied to the view if they are given to initialize. Those options and their types are el (element), model (state), collection (collection), pubSub (boolean), parent (object), subviewId (string).

``` coffee

class MyView extends Lanes.Views.Base

    initialize: (options)->
        this.magic = options.answer

view = new MyView( answer: 42 )
# view.magic => 42

```

# source

The "source" property is a way for Lanes to detect where the view was loaded from. When Lanes sets up a new class it sets it to the "magic" FILE variable.  Lanes Coffeescript pre-processor will set the FILE to the proper values for each file.  The Base View uses the information contained in source to auto-load views and models from the correct location.

# el

A reference to a DOM element that is controlled by the view.

All views have a single DOM element.  If a view does is not provided an el when it's created, it will construct one when the render method is called.

# template

Either an string or a function that returns a string.  The string can be either a path to a pre-compiled template, or a HTML string.


``` coffee
class MyView extends Lanes.Views.Base
    template: "<div><p>Hello World</p></div>"

view = new MyView
view.render()

# view.el.innerHTML => <div><p>Hello World</p></div>
```



``` coffee
class MyView extends Lanes.Views.Base
    template: "views/myview"

view = new MyView
# attempt to render a template from path "views/myview"
view.render()
```


``` coffee
# Contained in file MyView.coffee

class MyApp.Views.MyView extends Lanes.Views.Base
    source: FILE

view = new MyView
# will use the "source" information to render
# a template from "myapp/views/my_view"
view.render()
```

# templateName

A string (or function that returns one) that contains the name of a template.  The template will be loaded from the same path but using the templateName instead of one with the same name as the file.

``` coffee
class MyApp.Views.MyView extends Lanes.Views.Base
    source: FILE
    templateName: "contents"

view = new MyView
# will use the "source" information to render
# a template from "myapp/views/contents"
view.render()
```

# subviews

Subviews are View classes that should be rendered at a given point on the DOM once conditions are met.

In order for a subview to render, the parent's el must have a valid reference to the DOM element to render the subview into, as well as all data for the subview being present.

When Subviews are created they are passed the parent view and any other options that were specified.

Definitions for subviews apre specified using:

 * A "view" or "component" key, given either as a class or a string that contains the keypath to the object.
 * Either a "container" or "hook" reference.  If one is not given, it will default to a hook with the same name as the subview reference.  For instace the "heading" subview below will default to `data-hook="heading"`
 * A model or collection reference.  If a collection reference is given, the collection will render using a collectionView.
 * Options.  Either a object, a function, or a reference to a class method to call.


``` coffee
class MyApp.Views.MyView extends Lanes.Views.Base
    subviews:
        heading:
            view: MyApp.WeirdNamespace.Heading
            model: 'model.person'
            options: {uppercase: true}
        grid:
            component: "Grid"
            container: 'div.grid'
            options: 'gridOptions'
        names:
            view: "NamesItem"
            container: "div.names"
            collection: 'collection'
    gridOptions: -> { count: this.count() }
    template: "<div>
           <div data-hook='heading'></div>
           <div data-hook='finder'></div>
           <div class='grid'></div>
           <div class='names'></div>
        </div>"
```            

Notes:

 * **heading**
    * Is specified as a class object.  `MyApp.WeirdNamespace.Heading` must be defined prior to the file being read and should be a "view like" object.
    * It's model will be set to the value from `model.person`, and it will not be rendered until `model.person` is set to a truthy value.
    * When the view is created it will be passed `{uppercase: true}` as it's options.
    * No `selector` or `hook` was provided.  It will default to rendering to `data-hook="heading"`
 * **grid**
   * is using a component named "Grid".  When the subview is ready to be created, Lanes will look for a class in the "Components" namespace: `Lanes.Components.Grid`
   * Will render to the "div.grid" element.
   * It's options will be set from the value returned by calling the `gridOptions` method.
 * **names**
   * Since the "view" is given as a simple string, Lanes will search for it in the MyApp namespace, and will expect `MyApp.Views.NamesItem` to be defined
   * A collection is specified.  A collectionView will be created and the NamesItem class given as the child view to the collectionView.  The collectionView will then handle rendering the collection whenever it has items added/removed.
   

# subviewOptions(name,def)

When subviews are created, they are initialized with an options object containing the parent view, and any other options that are returned by the `subviewOptions` method.

The base view's implementation simply returns any options that were given on the subview's definition.

Other views may override this method as a convienct way to specify the same options for all subviews.

In the below example, each of the subviews will be initialied with:
`{ parent: (MyView instance), model: (MyView instance).model, status: "red"}`


``` coffee
class MyApp.Views.MyView extends Lanes.Views.Base
    subviews:
        heading:
            view: 'Heading'
        footer:
            view: 'Footer'
    subviewOptions: ->
        {model: @model, status: "red"}

```



# events

Listens for DOM events that occur within the view _(under it's el)_.  Events are specified as a
 hash containing "event selector" for the key and either a name of a method or function for the value.

If the selector is ommited, the event will be bound to the root element.


``` coffee
class MyApp.Views.MyView extends Lanes.Views.Base
    template: "<div><a class='title'>click me!</a></div>"
    events:
        "click .title": "onTitleClick"
        "click": -> console.log("I feel like I was clicked somewhere")
    onTitleClick: ->
        console.log "Title Was Clicked!"
```

# ui

A View will often need to access a given DOM element repeatedly.  By specifying a the elements as part of the UI property, they will be cached when the view is rendered for speedy access.

Additionally elements cached in the UI can be refered to in bindings as a convience.


``` coffee
class MyApp.Views.MyView extends Lanes.Views.Base
    ui:
        title: "a.title"
    template: "<div><a class='title'>click me!</a></div>"
    events:
        "click @ui.title": "onTitleClick"
    onTitleClick: ->
        console.log "Title Was Clicked!"
    performOperation: ->
        this.ui.title.hide()
        runOperation()
        this.ui.title.show()
```

### _Note:_ UI elements are not accessible until the view is rendered.

# query(selector)

Returns a single element based on CSS selector scoped to this.el
if you pass an empty string it return `this.el`.

Is more efficient that using the `$` method which calls out to jQuery

``` coffee
class MyView extends Lanes.Views.Base
    template: "<div><a class='title'>click me!</a></div>"

view = new MyView
view.render()
# get the first element the class "title"
view.query('.title').click()
```

# $(selector)

The same as `query`, but uses jQuery to find the selection, and may return more than just one
element.  Is essentially just a shortcut to running $el.find.  It runs queries scoped within the view's element.

``` coffee
class MyView extends Lanes.Views.Base
    template: "<div><a class='title'>click me!</a></div>"

view = new MyView
view.render()
# get the first element the class "title"
view.$('.title').click()
```

# parentScreen()

Walks up the parent chain, attempting to find a screen.  If it's found once is returned, otherwise returns null.

It's sometimes useful to relay events up to a level where the user can make note of them.  This method provides a way to obtain a reference to the owning screen.

# remove()

Recursively calls remove() on all subviews, than removes itself form the DOM and unbinds all event listeners.
