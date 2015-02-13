#= require ./ChangeListener

class ScreenBase

    abstractClass: true

    constructor: ->
        super

    mixins:[
        Lanes.Screens.ChangeListener
    ]

    reset: Lanes.emptyFn

    templateName: 'layout'

    render: ->
        previouslyRendered = this.rendered
        Lanes.Views.RenderContext.start(this)
        # Here we cheat and skip ViewBase so it doesn't push to context
        this.reset()
        this.renderContextFree()
        #Lanes.Views.Base.__super__.render.apply(this, arguments)
        this.renderAllSubviews() if previouslyRendered
        Lanes.Views.RenderContext.reset()
        this

    addButton: (config, align='left')->
        this.$(".toolbar ." + align).append( Lanes.Views.Helpers.button(config) )


# By doing extending in this fashion, the class will appear as ScreenBase
# during debugging, allowing it to be easily identified
Lanes.Screens.Base = Lanes.Views.Base.extend( ScreenBase )
