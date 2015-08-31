Lanes.Workspace.Mixins.Viewport = {

    contextTypes:
        viewport: Lanes.PropTypes.State

}


Object.defineProperty Lanes.React.Mixins.Viewport, 'uistate',
    get: ->
        @context.viewport
