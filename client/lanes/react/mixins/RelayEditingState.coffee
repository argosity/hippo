Lanes.React.Mixins.RelayEditingState = {
    childContextTypes:
        recordDisplay: React.PropTypes.oneOf(
            ['edit', 'display']
        )
        writable: React.PropTypes.bool
        readonly: React.PropTypes.bool

    getChildContext: ->
        context = {}
        context.recordDisplay = if @props.editOnly or @state.isEditing then 'edit' else 'display'
        if @props.readonly?
            context.readonly = @props.readonly
        if @props.writable?
            context.writable = @props.writable
        context

    setModelUrl: (model) ->
        @props.screen.model = model

}
