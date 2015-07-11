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
        <BS.Col {...colProps} >
            <BS.Input
                ref="input"
                className={_.classnames('value', changeset: @state.changeset)}
                type='text'
                label={label}
                value={@props.model[@props.name]}
                onChange={@handleChange}
                {...@props}
            />
        </BS.Col>
