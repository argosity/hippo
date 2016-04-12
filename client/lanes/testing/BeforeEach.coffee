SYNC_RESPONSE = {}

Lanes.Test.syncSucceedWith = (data) ->
    SYNC_RESPONSE.success = true
    SYNC_RESPONSE.total = data.length if _.isArray(data)
    SYNC_RESPONSE.data = _.cloneDeep(data)

Lanes.Test.syncRespondWith = (obj) ->
    _.extend(SYNC_RESPONSE, obj)

afterEach ->
    Lanes.current_user._events = @__user_events
    Lanes.Models.PubSub.types.reset()
    Lanes.Models.PubSub.mb = @prevMB

beforeEach ->
    @__user_events = Lanes.current_user._events
    Lanes.Models.ServerCache.MODELS = {}
    Lanes.Models.ServerCache.COLLECTIONS = {}
    window.LT = Lanes.Test

    SYNC_RESPONSE = {
        success: true
        message: ''
        data: []
    }

    @prevMB = Lanes.Models.PubSub.mb
    Lanes.Models.PubSub.mb = jasmine.createSpyObj('MessageBus', [
        'subscribe', 'unsubscribe'
    ])

    originalFn = Lanes.Models.Sync.perform
    spyOn(Lanes.Models.Sync, 'perform').and.callFake( (method, options) ->
        _.Promise.resolve(SYNC_RESPONSE)
    )
    Lanes.Models.Sync.perform.lastOptions = ->
        this.calls.mostRecent()?.args[1]
    Lanes.Models.Sync.restorePerform = (fn) ->
        spy = Lanes.Models.Sync.perform
        Lanes.Models.Sync.perform = originalFn
        try
            fn()
        finally
            Lanes.Models.Sync.perform = spy
