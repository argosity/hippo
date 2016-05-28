class Lanes.Components.FormGroup extends Lanes.React.Component

    mixins: [
        Lanes.React.Mixins.ReadEditingState
        Lanes.React.Mixins.FieldErrors
    ]

    propTypes:
        align: React.PropTypes.oneOf([
            'right', 'left', 'center'
        ])

    bindDataEvents: ->
        model: "invalid-fields invalid-field:#{@getInvalidFieldName()}"

    render: ->
        className = _.classnames(className, @props.className, "field"
            editing: @props.editing
            "align-#{@props.align}": @props.align
            display: false == @props.editing
            'has-error': @isFieldValueInvalid()
        )
        colProps = _.omit(@props, 'name', 'label', 'type', 'editing', 'display')
        valueClassNames = _.classnames('value', {
            "align-#{@props.align}": @props.align
        })
        <BS.Col {...colProps} className={className}>
            <BS.FormGroup className={valueClassNames}>
                <BS.ControlLabel>{@props.label}</BS.ControlLabel>
                {@props.children}
            </BS.FormGroup>
        </BS.Col>
