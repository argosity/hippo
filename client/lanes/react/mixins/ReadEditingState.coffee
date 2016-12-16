Lanes.React.Mixins.ReadEditingState = {
    contextTypes:
        recordDisplay:  React.PropTypes.oneOf(
            ['edit', 'display']
        )
        writable: React.PropTypes.bool
        readonly: React.PropTypes.bool

    propTypes:
        editOnly:  React.PropTypes.bool

    isEditingRecord: ->
        # if updated, also change Lanes.React.Mixins.FieldErrors.fieldInvalidValueMessage
        @props.editOnly or @context.recordDisplay == 'edit'
}
