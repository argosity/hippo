Lanes.React.Mixins.Viewport = {

    contextTypes:
        viewport: Lanes.PropTypes.State

}


Object.defineProperty Lanes.React.Mixins.Viewport, 'viewport',
    get: ->
        @context.viewport
