Lanes.Components.Form || = {}

Lanes.Components.Form.FieldMixin = {
    bindDataEvents: ->
        model: "change:#{@props.name} remote-update:#{@props.name} invalid-fields invalid-field:#{@getInvalidFieldName()}"

    mixins: [
        Lanes.React.Mixins.Access
        Lanes.React.Mixins.FieldErrors
        Lanes.React.Mixins.ReadEditingState
    ]

    pubsub: false
    propTypes:
        model: Lanes.PropTypes.State.isRequired
        name:  React.PropTypes.string.isRequired
        align: React.PropTypes.oneOf([
            'right', 'left', 'center'
        ])
        label: React.PropTypes.oneOfType([
            React.PropTypes.string, React.PropTypes.element
        ])
        onChange: React.PropTypes.func
        unstyled: React.PropTypes.bool
        getValue: React.PropTypes.func
        setValue: React.PropTypes.func

    _getValue: ->
        if @props.getValue
            @props.getValue.call(@model, @props)
        else
            @model[@props.name]

    _setValue: (value) ->
        if @props.setValue then @props.setValue(value) else @model[@props.name] = value

    unsetChangeSet: ->
        @setState(changeset: false) if @isMounted()

    setDataState: (state, evname) ->
        changeset = evname == "changeset"
        if changeset
            _.delay(@unsetChangeSet, 2000)
        @setState  _.extend(state, {changeset: changeset})

    handleChange: (ev) ->
        if @props.onChange
            @props.onChange(ev)
        else
            @_setValue(ev.target.value)
        null

    renderMixinDisplayValue: ->
        value = @_getValue() || ""
        value = String(value) if _.isObject(value) or not value
        <span>{value}</span>

    formGroupClassNames: ->
        _.classnames(
            _.result(this, 'formGroupClass')
        )

    _mixinRenderValue: (label, className) ->
        value = (@renderDisplayValue || @renderMixinDisplayValue)?()
        className = _.classnames(@props.className, className, {
            "align-#{@props.align}": @props.align
        })
        if @props.unstyled
            value
        else
            <LC.FormGroup display {...@props}
                className={className} label={label}
            >
                {value}
            </LC.FormGroup>

    getLabelValue: ->
        @props.label || _.titleize _.humanize @props.name

    render: ->
        unless @props.unlabeled
            label =
                <LC.ControlLabel {...@props} titleOnly
                    label={@getLabelValue()} />

        if @isEditingRecord()
            if @hasWriteAccess()
                @renderEdit(label)
            else if @hasReadAccess()
                (@renderReadOnly || @_mixinRenderValue)(label, "read-only")
            else
                <span />
        else
            if @hasReadAccess()
                (@renderDisplay || @_mixinRenderValue)(label, "display")
            else
                <span/>

}
