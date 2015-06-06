Lanes.Test.makeComponent = (props = {}, args = {}) ->
    class TestComponent
        render: -> React.createElement('div', 'hello')
    _.extend(TestComponent.prototype, props)
    Component = Lanes.React.Component.extend(TestComponent)
    Lanes.Test.renderComponent(Component, args)

Lanes.Test.defineModel = (props = {}) ->
    class TestModel
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
            constructor: -> super
        TestCollection::model = Lanes.Models.Base.extend(TestModel)
    Lanes.Models.Collection.extend(TestCollection)
    return new TestCollection(args)
