class Lanes.Components.TextField extends Lanes.React.Component

    mixins: [
        Lanes.Components.Form.FieldMixin
    ]

    propTypes:
        unlabled:  React.PropTypes.bool

    getValue: ->
        @refs.input.getValue()

    renderEdit: (label) ->
        colProps = _.omit(@props, 'name')
        <BS.Col {...colProps} >
            <BS.Input
                {...@props}
                ref="input"
                className={_.classnames('value', changeset: @state.changeset)}
                type='text'
                label={label}
                value={@props.model[@props.name]}
                onChange={@handleChange}
            />
        </BS.Col>
