Lanes.Components.Form || = {}

Lanes.Components.Form.FieldMixin = {
    bindDataEvents: ->
        model: "change:#{@props.name} remote-update:#{@props.name}"

    mixins: [
        Lanes.React.Mixins.Access
        Lanes.React.Mixins.ReadEditingState
    ]

    pubsub: false
    propTypes:
        model: Lanes.PropTypes.State.isRequired
        name:  React.PropTypes.string.isRequired
        label: React.PropTypes.string
        onChange: React.PropTypes.func
        unstyled: React.PropTypes.bool

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
            @props.model[@props.name] = ev.target.value
        null

    renderMixinDisplayValue: ->
        value = @props.model[@props.name] || ""
        value = String(value) if _.isObject(value) or not value
        <span>{value}</span>

    formGroupClassNames: ->
        _.classnames('form-group',
            _.result(this, 'formGroupClass')
            editing: @isEditingRecord()
        )

    _mixinRenderValue: (label, className) ->
        value = (@renderDisplayValue || @renderMixinDisplayValue)?()
        if @props.unstyled
            value
        else
            className = _.classnames(className, "value", changeset: @state.changeset)
            colProps = _.omit(@props, 'name', 'label')
            <BS.Col {...colProps}>
                <div className={@formGroupClassNames()}>
                    <label className='field'>
                        <div className="title">{label}</div>
                        <div className={className} name={@props.name}>
                            {value}
                        </div>
                    </label>
                </div>
            </BS.Col>

    render: ->
        unless @props.unlabeled
            label = @props.label || _.titleize _.humanize @props.name
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
