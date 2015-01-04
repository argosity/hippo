Lanes.namespace 'Test'

View       = undefined
Model      = undefined
Collection = undefined

class Lanes.Test.DummyView extends Lanes.Views.Base
    template: "<p>hi</p"
    events: { "click #mylink": 'onClick' }
    onClick: Lanes.emptyFn

class Lanes.Test.DummyModel extends Lanes.Models.Base
    api_path: "test"
    props:
        id: 'number',
        name: ['string', true],
        html: 'string',
        url: 'string',
        something: 'string',
        fireDanger: 'string'

    session:
        active: 'boolean'

    derived:
        classes:
            deps: ['something', 'fireDanger', 'active'],
            fn: -> this.something + this.active;

Lanes.Test.makeModel = (props={}, args={})->
    _.extend(Model.prototype, props)
    Lanes.Models.Base.extend(Model)
    Collection::model = Model
    Lanes.Models.Collection.extend(Collection)
    collection = new Collection
    return collection.add(new Model(args))

Lanes.Test.makeView = (props={}, args={})->
    _.extend(View.prototype, props)
    Lanes.Views.Base.extend(View)
    return new View(args)

syncResponse = (method, model, options)->
    _.defer ->
        if options.success && syncReply.success
            options.success(syncReply, "success", {})
        if options.failure && !syncReply.success
            options.failure(syncReply, "failure", {})
        _.Promise.resolve(model, options)

syncReply = {}

Lanes.Vendor.MessageBus = {
    subscribe:   jasmine.createSpy('subscribe')
    unsubscribe: jasmine.createSpy('unsubscribe')
    start: Lanes.emptyFn
}

window.syncSucceedWith = (data)->
    syncReply.success = true
    syncReply.data = data

beforeEach ->
    class TestModel
        constructor: -> super
    Model = TestModel
    class TestCollection
        constructor: -> super
    Collection = TestCollection
    class TestView
        constructor: -> super
    View = TestView

    syncReply = {
        success: true
        message: ''
        data: {}
    }
    
    Lanes.Test.syncSpy = jasmine.createSpy('sync').and.callFake(syncResponse)
    Lanes.Test.syncSpy.lastOptions = ->
        this.calls.mostRecent().args[2]
    Lanes.Models.Base::sync       = Lanes.Test.syncSpy
    Lanes.Models.Collection::sync = Lanes.Test.syncSpy


