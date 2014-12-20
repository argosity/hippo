Lanes.namespace 'Testing'

class Lanes.Testing.View extends Lanes.Views.Base
    template: "<p>hi</p"
    events: { "click #mylink": 'onClick' }
    onClick: Lanes.emptyFn

Lanes.Vendor.MessageBus = {
    subscribe:   jasmine.createSpy('subscribe')
    unsubscribe: jasmine.createSpy('unsubscribe')
    start: Lanes.emptyFn
}
    
class Lanes.Testing.Model extends Lanes.Data.Model
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

class Lanes.Testing.Collection extends Lanes.Data.Collection
    model: Lanes.Testing.Model

syncResponse = (method,model,options)->
    if options.success && syncReply.success
        options.success(model, syncReply, {})
    if options.failure && !syncReply.success
        options.failure(model, syncReply, {})
    _.Promise.resolve(model,options)

syncReply = {}

window.syncSucceedWith = (data)->
    syncReply.success = true
    syncReply.data = data
    
beforeEach ->

    syncReply = {
        success: true
        message: ''
        data: {}
    }
    
    Lanes.Testing.syncSpy = jasmine.createSpy('sync').and.callFake(syncResponse)
    Lanes.Testing.syncSpy.lastOptions = ->
        this.calls.mostRecent().args[2]
    Lanes.Data.Model::sync      = Lanes.Testing.syncSpy
    Lanes.Data.Collection::sync = Lanes.Testing.syncSpy


