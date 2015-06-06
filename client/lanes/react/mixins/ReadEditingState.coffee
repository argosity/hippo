Lanes.React.Mixins.ReadEditingState = {
    contextTypes:
        recordDisplay:  React.PropTypes.oneOf(
            ['edit', 'display']
        )
        writable: React.PropTypes.bool
        readonly: React.PropTypes.bool

    isEditingRecord: ->
        @props.editOnly or @context.recordDisplay == 'edit'
}
