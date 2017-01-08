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

    renderDisplay: (props) ->
        clean = LC.Form.FieldMixin.statics.cleanSizeProps(props)
        <BS.FormControl.Static {...clean}>
            {@getDateValue().format(this.props.format)}
        </BS.FormControl.Static>

    getDateValue: ->
        _.moment.utc(@fieldMixinGetValue())

    handleDateTimeChange: (val) ->
        @fieldMixinSetValue({target: {value: Lanes.u.utcToLocalDate(val)}})

    renderEdit: (props) ->
        props = _.extend({
            ref:       'control'
            value:     Lanes.u.dateToUTC(@getDateValue().toDate())
            onChange:  @handleDateTimeChange
        }, @props)
        props = _.omit(LC.Form.FieldMixin.statics.cleanSizeProps(props), 'writable')
        <Lanes.Vendor.ReactWidgets.DateTimePicker
            {...props}
        />
