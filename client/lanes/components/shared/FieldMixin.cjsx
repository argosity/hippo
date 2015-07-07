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
        unstyled: React.PropTypes.bool

    unsetChangeSet: ->
        @setState(changeset: false) if @isMounted()

    setDataState: (state, evname) ->
        changeset = evname == "changeset"
        if changeset
            _.delay(@unsetChangeSet, 2000)
        @setState  _.extend(state, {changeset: changeset})


    handleChange: (ev) ->
        @props.model[@props.name] = ev.target.value
        null

    renderMixinDisplayValue: ->
        value = @props.model[@props.name] || ""
        value = String(value) if _.isObject(value) or not value
        <span>{value}</span>

    _mixinRenderValue: (label, className) ->
        value = (@renderDisplayValue || @renderMixinDisplayValue)?()
        if @props.unstyled
            value
        else
            className = _.classnames(className, "value", changeset: @state.changeset)
            <BS.Col {...@props}>
                <div className="form-group">
                    <label className='field read-only'>
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
