class Lanes.Components.DateTime extends Lanes.React.Component

    mixins: [
        Lanes.Components.Form.FieldMixin
    ]
    fieldClassName: 'date-time'

    getDefaultProps: ->
        format: 'ddd, MMM Do YYYY, h:mm a'

    propTypes:
        unlabled: React.PropTypes.bool
        format:   React.PropTypes.string


    handleKeyDown: (ev) ->
        @props.onEnter() if ev.key is 'Enter'

    handleDateTimeChange: (val) ->
        @fieldMixinSetValue({target: {value: val}})

    renderDisplay: (props) ->
        clean = LC.Form.FieldMixin.statics.cleanSizeProps(props)
        <BS.FormControl.Static {...clean}>
            {_.moment(@model[@props.name]).format(@props.format)}
        </BS.FormControl.Static>

    renderEdit: (props) ->
        props = _.extend({
            ref:       'control'
            value:     _.moment(@fieldMixinGetValue() || new Date()).toDate()
            onChange:  @handleDateTimeChange
        }, @props)
        props = _.omit(LC.Form.FieldMixin.statics.cleanSizeProps(props), 'writable')
        <Lanes.Vendor.ReactWidgets.DateTimePicker
            {...props}
        />
