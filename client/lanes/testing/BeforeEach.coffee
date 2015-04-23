window.syncSucceedWith = (data)->
    syncReply.success = true
    syncReply.data = data


syncResponse = (method, model, options)->
    _.defer ->
        if options.success && syncReply.success
            options.success(syncReply, "success", {})
        if options.failure && !syncReply.success
            options.failure(syncReply, "failure", {})
        _.Promise.resolve(model, options)

syncReply = {}

View       = undefined
Model      = undefined
Collection = undefined

Lanes.Test.makeModel = (props={}, args={})->
    _.extend(Model.prototype, props)
    Lanes.Models.Base.extend(Model)
    return new Model(args)

Lanes.Test.makeView = (props={}, args={})->
    _.extend(View.prototype, props)
    Lanes.Views.Base.extend(View)
    return new View(args)

beforeEach ->
    Lanes.Models.ServerCache.CACHE = {};

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

    # Lanes.Test.syncSpy = jasmine.createSpy('sync').and.callFake(syncResponse)
    # Lanes.Test.syncSpy.lastOptions = ->
    #     this.calls.mostRecent().args[2]
    originalFn=Lanes.Models.Sync.perform
    spyOn(Lanes.Models.Sync, 'perform').and.callFake(syncResponse)
    Lanes.Models.Sync.perform.lastOptions = ->
        this.calls.mostRecent().args[2]
    Lanes.Models.Sync.callOriginal = (fn)->
        spy=Lanes.Models.Sync.perform
        Lanes.Models.Sync.perform = originalFn
        try
            fn()
        finally
            Lanes.Models.Sync.perform=spy
