class Lanes.Components.DisplayValue extends Lanes.React.Component

    mixins: [
        Lanes.Components.Form.FieldMixin
    ]
    fieldClassName: 'display-value'

    renderEdit: (props) ->
        <BS.FormControl.Static {...props}>
            {@fieldMixinGetValue()}
        </BS.FormControl.Static>
