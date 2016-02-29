class Lanes.Components.DisplayValue extends Lanes.React.Component

    mixins: [
        Lanes.Components.Form.FieldMixin
    ]
    formGroupClass: 'display'

    renderEdit: (label) ->
        value = @_getValue()
        <LC.FormGroup
            {...@props}
            className={@formGroupClassNames()}
            label={@getLabelValue()}
        >
            {value}
        </LC.FormGroup>
