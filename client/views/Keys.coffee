km = Lanes.Vendor.KeyMaster

Lanes.Views.Keys = {

    scopes:{}
    defaultTime: 5000

    setScopeTimer: (scope)->
        @timeout = _.delay( =>
            km.setScope('none')
        ,@defaultTime)

    rescheduleTimeout: (scope)->
        return unless @timeout
        clearTimeout(@timeout)
        this.setScopeTimer(scope)
        Lanes.Views.TimedHighlight.reset(scope.time || @defaultTime)

    addScope:(scope)->
        km(scope.shortcut, (ev)=>
            km.setScope(scope.name)
            for view in scope.views
                Lanes.Views.TimedHighlight.on(view, scope.time || @defaultTime)

            @setScopeTimer() unless scope.permanent

            return false
        )
        scope.views = []
        @scopes[scope.name] = scope

    addEvent: (keys, handler, view, scope)->
        km(keys, scope.name, (ev)=>
            view[handler].call(view, ev)
            @rescheduleTimeout(scope)

        )

    add: (view, events, scope)->
        scope = @scopes[scope.name] || this.addScope(scope)
        scope.views.push(view)
        for keys, handler of events
            this.addEvent(keys, handler, view, scope)

    remove: (view, events, scope)->
        scope = @scopes[scope.name]
        scope.views.remove(view)
        for keys, handler of events
            km.unbind(keys,scope.name)

        if 0==scopes.views.length
            km.unbind(scope.shortcut,'all')
            delete @scopes[scope.name]


    initialize: ->
        km.filter = -> true

}