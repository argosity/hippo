window.syncSucceedWith = (data) ->
    syncReply.success = true
    syncReply.data = data

syncResponse = (method, options) ->
    new _.Promise( (resolve, reject) ->
        _.defer -> resolve(syncReply)
    )


syncReply = {}

afterEach ->
    Lanes.current_user._events = @__user_events

beforeEach ->
    @__user_events = Lanes.current_user._events
    Lanes.Models.ServerCache.MODELS = {}
    Lanes.Models.ServerCache.COLLECTIONS = {}
    window.LT = Lanes.Test

    syncReply = {
        success: true
        message: ''
        data: {}
    }

    originalFn = Lanes.Models.Sync.perform
    spyOn(Lanes.Models.Sync, 'perform').and.callFake(syncResponse)
    Lanes.Models.Sync.perform.lastOptions = ->
        this.calls.mostRecent().args[1]
    Lanes.Models.Sync.restorePerform = (fn) ->
        spy = Lanes.Models.Sync.perform
        Lanes.Models.Sync.perform = originalFn
        try
            fn()
        finally
            Lanes.Models.Sync.perform = spy
