---
title: React
heading: Hippo.React.Component
---

Hippo uses [React](reactjs.com) for the view layer.  It provides an easy-to-use data bindings between it and the data layouer's {% doc_link model %}

A simple example of a React component bound to a data model:

``` coffee

class MyView extends Hippo.React.Component

    propTypes:
        model: Hippo.PropTypes.Model.isRequired

    render: ->
        <h1>Hello {@model.name}</h1>

```

Note a few interesting things about this component compared to a standard React one.  The first is the non-standard "model" propType, and the second is the @model instance variable used in the `render` method.

# propType validators

As show above, Hippo provides validators for it's data types.  These include:


  * `Hippo.PropTypes.Model` Verifies that the property is an instance of `Hippo.Models.Base`
  * `Hippo.PropTypes.State` Checks that the property is an instance of `Hippo.Models.State`.  State objects are like models, but do not have the ability to be retreived from or saved to the server.  They're usefull for storing lightweight session objects.
  * `Hippo.PropTypes.Collection` Like the models above but for collections.

Each of the validators also has a `.isRequired` helper, just like React's built in ones.

# dataObjects

Hippo data bindings for components will be automatically setup for any prop that is named `model`.

If a property named `model` is given, it will be mapped to the `@model` instance.  Other properties can also be setup by specifying attributes for `dataObject`  In this example, a '@bank` and `@customer` objects are mapped.

``` coffee

class MyView extends Hippo.React.Component

    dataObjects:
        bank: 'props'
        customer: -> GlobalCustomer.lookup('foo')

    render: ->
        <h1>{@customer.name} has {@bank.balance}</h1>

```

As you can see, the bank mapping will be read from the props, while the customer uses a custom lookup strategy.  It's function will be called to obtain the value whenever the component is mounted.



# events

By default, Hippo will listen for all events on both models and collections.

Every time the events fires, Hippo will call `setState` on the component, causing a re-render.  While React is great about making the re-render as efficient as possible, it can sometimes be a good idea to only listen for events that the compoent will be interested int.

The events bound can be modified by using the `bindDataEvents` attribute.  For instance this component will only render when the name is changed.  This makes sense since that's the only attribute of the model that is used.


``` coffee

class MyView extends Hippo.React.Component

    bindDataEvents:
        model: 'change:name'


    render: ->
        <h1>Your name is: {@model.name}</h1>

```

The complete list of events Hippo listens to is:

  * Models:
    * `change`:   an attribute was modified
    * `request`: A network request was began
    * `sync`: The network request completed
    * `invalid`: An attempted update failed validation
    * `error`: An error was encountered, usually only fired during network access.
  * Collections:
    * `add`: A model was added
    * `remove`: Model removed
    * `change`: one of the models was changed
    * `sort`: The collection was re-sorted
    * `reset`: All models were removed
    * `request`: A network request was started
    * `sync`: Network request completed
    * `error`: An error occured, usually during network access

# setDataState

When a bound event is fired for a model, Hippo will call setState on the model with the affected model as the key. Sometimes a component would rather have other information injected into state, or perhaps wants to selectively ignore some changes.

Components can do so by implementing a `setDataState` method.  If this method exists, it is soley responsible for calling `setState` to trigger a `render`

``` coffee

class MyView extends Hippo.React.Component

    setDataState: (newState) ->
        if newState.model?.name == 'Bob'
            this.setState(wasBob: true)

    render: ->
        <h1>Has Bob been seen? {if @state.wasBob then 'Yes' else 'No'}</h1>

```

# PubSub

Publish/Subscribe often abbreviated as simply PubSub is a mechanism where amodel can subscribe to updates for itself and be notified when other users modify it.

By default whenever a model is bound to a React component, Hippo will also subscribe that model to updates.  When model is unbound or the component is unmounted, Hippo will remove the model from receiving updates as well.  This applies only to Models, not State object or Collections.

Set `pubsub: false` if Hippo should not bind any models, or to an object with keys for the models that should not be bound


``` coffee

class MyView extends Hippo.React.Component

    pubsub:
        model: false

    # could also have just been:
    pubsub: false


```
