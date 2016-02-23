class Lanes.Components.FormGroup extends Lanes.React.Component

    mixins: [
        Lanes.React.Mixins.ReadEditingState
        Lanes.React.Mixins.FieldErrors
    ]

    bindDataEvents: ->
        model: "invalid-fields invalid-field:#{@getInvalidFieldName()}"

    render: ->
        className = _.classnames(className, @props.className, "field"
            editing: @props.editing
            display: false == @props.editing
            'has-error': @isFieldValueInvalid()
        )

        colProps = _.omit(@props, 'name', 'label', 'type', 'editing', 'display')

        <BS.Col {...colProps} className={className}>
            <div className="form-group">
                <LC.ControlLabel {...@props}>
                    <div className="input-group" name={@props.name}>
                        <div className="value">
                            {@props.children}
                        </div>
                    </div>
                </LC.ControlLabel>
            </div>
        </BS.Col>
