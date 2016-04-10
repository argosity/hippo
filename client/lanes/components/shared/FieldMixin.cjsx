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
            @props.getValue.call(@model, @props) or ''
        else
            @model[@props.name] or ''

    _setValue: (value) ->
        if @props.setValue then @props.setValue(value) else @model[@props.name] = value

    componentWillUnmount: ->
        clearTimeout(@state.pendingChangeSetDelay) if @state.pendingChangeSetDelay

    _unsetChangeSet: ->
        @setState(displayChangeset: false, pendingChangeSetDelay: null)

    setDataState: (state, evname) ->
        displayChangeset = @model.updatingFromChangeset and @model.changedAttributes()[@props.name]
        if displayChangeset
            pendingChangeSetDelay = _.delay(@_unsetChangeSet, 2000)
        @setState(_.extend( state, {pendingChangeSetDelay, displayChangeset}))

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
        _.classnames( _.result(this, 'formGroupClass'), {
            changeset: @state.displayChangeset
        })

    _mixinRenderValue: (label, className) ->
        value = (@renderDisplayValue || @renderMixinDisplayValue)?()
        className = _.classnames(@props.className, className, @formGroupClassNames(), {
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
