class Lanes.Components.Input extends Lanes.React.Component

    mixins: [
        Lanes.Components.Form.FieldMixin
    ]
    formGroupClass: 'input'

    propTypes:
        unlabled:  React.PropTypes.bool

    getValue: ->
        @refs.input.getValue()

    renderEdit: (label) ->
        colProps = _.omit(@props, 'name')
        value = @props.model[@props.name] or ''
        <BS.Col {...colProps} >
            <BS.Input
                ref="input"
                className={_.classnames('value', changeset: @state.changeset)}
                type='text'
                label={label}
                value={value}
                onChange={@handleChange}
                {...@props}
            />
        </BS.Col>
