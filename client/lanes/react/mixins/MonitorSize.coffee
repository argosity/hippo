Lanes.React.Mixins.MonitorSize = {
    contextTypes:
        viewport: Lanes.PropTypes.State.isRequired

    _updateViewportSize: ->
        this.setState(_.pick(@context.viewport, 'width', 'height'))

    componentDidMount: ->
        if @context.viewport
            @data.listenTo(@context.viewport, 'change:height change:width', @_updateViewportSize)
}
