class Lanes.Components.DateTime extends Lanes.React.Component

    mixins: [
        Lanes.Components.Form.FieldMixin
    ]
    formGroupClass: 'date-time'

    getDefaultProps: ->
        format: 'ddd, MMM Do YYYY, h:mm a'

    propTypes:
        unlabled: React.PropTypes.bool
        format:   React.PropTypes.string

    getValue: ->
        @refs.input.getValue()

    handleKeyDown: (ev) ->
        @props.onEnter() if ev.key is 'Enter'

    handleDateTimeChange: (val) ->
        @handleChange({target: {value: val}})

    renderEdit: (label) ->
        value = @_getValue() or ''
        props = _.extend({
            ref:       'control'
            className: _.classnames('value', changeset: @state.changeset)
            label:     if @props.unlabeled then false else label
            value:     value
            onChange:  @handleDateTimeChange
        }, @props)
        if @props.inputOnly then @renderPlain(props) else @renderStyled(props, label)

    renderPlain: (props) ->
        <Lanes.Vendor.ReactWidgets.DateTimePicker {...props} />

    renderStyled: (props, label) ->
        colProps = _.omit(props, 'name', 'value', 'label')
        <BS.Col {...colProps}>
            <div className={@formGroupClassNames()}>
                <label className="control-label">{label}</label>
                <div className="value">
                    <Lanes.Vendor.ReactWidgets.DateTimePicker {...props} />
                </div>
            </div>
        </BS.Col>