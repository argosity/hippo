class Lanes.Components.FieldWrapper extends Lanes.React.BaseComponent

    mixins: [
        Lanes.React.Mixins.ReadEditingState
    ]

    render: ->
        props = _.omit(@props, 'value')
        isEdit = @isEditingRecord()
        className = _.classnames(props.className, display: !isEdit)
        <LC.FormGroup {...props} className={className}>
            {if isEdit then @props.children else @props.value}
        </LC.FormGroup>
