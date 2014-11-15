Lanes.View.RenderContext = {

    stack: []

    reset: ()->
        @stack  = []

    start: (@parent, model=@parent.model)->
        @stack = [[@parent,model]]

    push: (identifier, model)->
        @stack.push([identifier,model])
        @_grants = null

    model: ->
        @stack[ @stack.length-1 ][1]?.modelForAccess()

    view: ->
        @stack[ @stack.length-1 ][0]

    canRead: (field)->
        Lanes.current_user.canRead( this.model(), field )

    canWrite: (field)->
        Lanes.current_user.canWrite( this.model(), field )

    pop: ->
        @stack.pop()



}
