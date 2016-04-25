class FakeNumberEvent
    constructor: (value) ->
        value = if _.isNull(value) then 0 else value
        @target = {value}
    isDefaultPrevented: -> false

class Lanes.Components.NumberInput extends Lanes.React.Component

    mixins: [
        Lanes.Components.Form.InputFieldMixin
    ]

    handleNumberChange: (n) ->
        @fieldMixinSetValue( new FakeNumberEvent(n) )

    renderInputField: (props, handlers) ->

        props.format ||= '#,###.00'
        props = _.omit(props, 'label')

        <Lanes.Vendor.ReactWidgets.NumberPicker
            ref="select"

            {...handlers}
            {...props}
            onChange={@handleNumberChange}
            value={Number(props.value)}
        />
