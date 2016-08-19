Lanes.Test.makeScreen = (props = {}, args = {}) ->
    class TestScreen
        FILE: { path: ['test'] }
        render: -> React.createElement('div')
    _.extend(TestScreen.prototype, props)
    Screen = Lanes.React.Screen.extend(TestScreen)
    Lanes.Test.renderComponent(Screen, props: args)


Lanes.Test.makeComponent = (props = {}, args = {}) ->
    class TestComponent
        FILE: { path: ['test'] }
        render: -> React.createElement('div')
    _.extend(TestComponent.prototype, props)
    Component = Lanes.React.Component.extend(TestComponent)
    Lanes.Test.renderComponent(Component, props: args)

Lanes.Test.defineModel = (props = {}) ->
    class TestModel
        FILE: { path: ['test'] }
        constructor: -> super
    _.extend(TestModel.prototype, props)
    Lanes.Models.Base.extend(TestModel)

Lanes.Test.makeModel = (props = {}, args = {}, options = {}) ->
    Model = Lanes.Test.defineModel(props)
    return new Model(args, options)

Lanes.Test.makeCollection = (props = {}, args = {}) ->
    class TestCollection
        constructor: -> super
    _.extend(TestCollection.prototype, props)
    unless TestCollection::model
        class TestModel
            FILE: { path: ['test'] }
            constructor: -> super
        TestCollection::model = Lanes.Models.Base.extend(TestModel)
    Lanes.Models.Collection.extend(TestCollection)
    return new TestCollection(args)
