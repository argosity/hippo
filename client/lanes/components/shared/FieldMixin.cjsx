Lanes.Components.Form || = {}

Lanes.Components.Form.FieldMixin = {
    bindDataEvents: ->
        model: "change:#{@props.name} remote-update:#{@props.name} invalid-fields invalid-field:#{@getInvalidFieldName()}"

    mixins: [
        Lanes.React.Mixins.Access
        Lanes.React.Mixins.ReadEditingState

        Lanes.React.Mixins.FieldErrors
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
        unlabled:     React.PropTypes.bool

        onChange: React.PropTypes.func
        unstyled: React.PropTypes.bool
        getValue: React.PropTypes.func
        setValue: React.PropTypes.func

    fieldMixinSetValue: (ev) ->
        if @props.onChange
            @props.onChange(ev)
        unless ev.isDefaultPrevented()
            @model[@props.name] = ev.target.value

    componentWillUnmount: ->
        clearTimeout(@state.pendingChangeSetDelay) if @state.pendingChangeSetDelay

    _unsetChangeSet: ->
        @setState(displayChangeset: false, pendingChangeSetDelay: null)

    setDataState: (state, evname) ->
        displayChangeset = @model.updatingFromChangeset and @model.changedAttributes()[@props.name]
        if displayChangeset and not @state.pendingChangeSetDelay
            pendingChangeSetDelay = _.delay(@_unsetChangeSet, 2000)
        @setState(_.extend( state, {pendingChangeSetDelay, displayChangeset}))

    _fieldMixinGetLabelValue: ->
        @getLabelValue?() ||
            @props.label ||
            _.titleize _.humanize @props.name

    fieldMixinGetValue: ->
        value = if @props.getValue
            @props.getValue.call(@model, @props)
        else if @props.value?
            @props.value
        else if @getValue
            @getValue()
        else
            @model[@props.name]
        if _.isBlank(value)
            ''
        else
            value

    _fieldMixinRenderFormGroup: (child, props, options) ->
        if (invalidMsg = @fieldInvalidValueMessage())
            msg = <BS.HelpBlock>{invalidMsg}</BS.HelpBlock>
        <BS.Col {...props}>
            <BS.FormGroup validationState={options.validationState}>
                <BS.ControlLabel>
                    {@_fieldMixinGetLabelValue()}
                </BS.ControlLabel>
                {child}
                <BS.FormControl.Feedback />
                {msg}
            </BS.FormGroup>
        </BS.Col>

    _fieldMixinRenderEdit: (props) ->
        <BS.FormControl
            type={@props.type || "text"}
            value={@fieldMixinGetValue()}
            {...props}
        />

    _fieldMixinRenderDisplay: (props) ->
        value = @fieldMixinGetValue()
        value = value.toString() if _.isObject(value)

        <BS.FormControl.Static {...props}>
            {value}
        </BS.FormControl.Static>

    _fieldMixinRenderNone: (props) ->
        <span {...props} />

    renderType: ->
        if @isEditingRecord()
            if @hasWriteAccess()
                ['edit', 'Edit']
            else if @hasReadAccess()
                ['read-only', 'Display']
            else
                ['none', 'None']
        else
            if @hasReadAccess()
                ['display', 'Display']
            else
                ['none', 'None']

    render: ->
        [type, method] = @renderType()
        options = {}

        hasError = @isFieldValueInvalid()
        options.validationState = 'warning' if hasError
        props = _.omit @props, 'model', 'label', 'name', 'unlabeled'
        props.className = _.classnames(
            _.result(this, 'fieldClassName'),
            'lanes-field', type, props.className,
            ( if @props.align then "align-#{@props.align}" else null),
            {
                changeset: @state.displayChangeset
                'has-error': hasError
            }
        )

        field = (@[ "render#{method}" ] || @["_fieldMixinRender#{method}"])(
            if @props.unlabeled then props else {}
        )
        if @props.unlabeled
            field
        else
            ( @['renderFormGroup'] || @['_fieldMixinRenderFormGroup'] )(field, props, options)

}
