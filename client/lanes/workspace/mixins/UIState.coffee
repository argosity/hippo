Lanes.Workspace.Mixins.UIState = {
    contextTypes:
        uistate: Lanes.PropTypes.State
}

Object.defineProperty Lanes.React.Mixins.Viewport, 'uistate',
    get: ->
        @context.viewport
