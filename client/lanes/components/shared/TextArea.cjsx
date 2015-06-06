class Lanes.Components.TextArea extends Lanes.React.Component

    mixins: [
        Lanes.Components.Form.FieldMixin
    ]

    propTypes:
        unlabled:  React.PropTypes.bool

    renderEdit: (label) ->
        <BS.Col {...@props}>
            <BS.Input
                className={_.classnames('lanes-input', changeset: @state.changeset)}
                type='textarea'
                label={label}
                value={@props.model[@props.name]}
                onChange={@handleChange}
                {...@props}/>
        </BS.Col>
