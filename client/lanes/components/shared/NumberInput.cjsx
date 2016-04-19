class Lanes.Components.NumberInput extends Lanes.React.Component

    mixins: [
        Lanes.Components.Form.InputFieldMixin
    ]
    handleNumberChange: (n) ->
        value = if _.isNull(n) then 0 else n
        @handleChange(target: {value})

    renderInputField: (props, handlers, label) ->
        props.format ||= '#,###.00'
        props = _.omit(props, 'label')

        <Lanes.Vendor.ReactWidgets.NumberPicker
            ref="select"
            className={@props.className}
            {...handlers}
            {...props}
            onChange={@handleNumberChange}
            value={Number(props.value)}
        />
