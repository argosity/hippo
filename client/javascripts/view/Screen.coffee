Lanes.namespace( 'Screens' )

class Lanes.View.Screen extends Lanes.View.Base

    namespace: "Screens"

    mixins:[
        Lanes.View.mixins.ScreenChangeListener
    ]

    initializeChanges:->
        @_changeListeners = {}
        for keypath in ( @usingModels || ['model'] )
            @_changeListeners[keypath] = new Lanes.View.ScreenChangeListener(this, keypath)

    reset: Lanes.emptyFn

    render: ->
        previouslyRendered = this.rendered
        Lanes.View.RenderContext.start(this)
        # Lanes.re we cheat and skip ViewBase so it doesn't push to context
        this.reset()
        this.renderContextFree()
        #Lanes.View.Base.__super__.render.apply(this, arguments)
        this.renderAllSubviews() if previouslyRendered
        Lanes.View.RenderContext.reset()
        this

    addButton: (config, align='left')->
        this.$(".toolbar ." + align).append( Lanes.View.Helpers.button(config) )
