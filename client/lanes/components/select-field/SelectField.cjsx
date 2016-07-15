class Lanes.Components.SelectField extends Lanes.React.Component
    mixins: [ Lanes.Components.Form.FieldMixin ]

    propTypes:
        choices: React.PropTypes.arrayOf(
            React.PropTypes.object
        )
        model:        Lanes.PropTypes.State.isRequired
        idField:      React.PropTypes.string
        labelField:   React.PropTypes.string
        getSelection: React.PropTypes.func
        setSelection: React.PropTypes.func
        displayLimit: React.PropTypes.number
        syncOptions:  React.PropTypes.object
        multiSelect:  React.PropTypes.bool
        includeBlankRow: React.PropTypes.bool

    getDefaultProps: ->
        labelField: 'label', idField: 'id'

    fieldClassName: 'select'

    modelBindings:
        query: ->
            src = @props.queryModel or
                @props.model.associations?.collectionFor(@props.name).model
            query = new Lanes.Models.Query({
                syncOptions: Lanes.Models.Query.mergedSyncOptions(@props.syncOptions)
                src: src
                fields: [
                    {id: @props.idField, visible: false},
                    @props.labelField
                ]
            })

    getValue: ->
        return undefined if @state.isOpen and not @props.multiSelect
        return @state.tempDisplayValue if @state.tempDisplayValue
        model = @props.getSelection?(@model, @props) or @model?[@props.name]
        return model if @props.multiSelect or not model?
        label = model[@props.labelField] or @props.defaultLabel
        if !label and not _.isEmpty(@props.choices)
            label = _.find( @props.choices, id: model.id)?[@props.labelField]
        if label
            {id: model.id, "#{@props.labelField}": label}
        else if model.id
            model.id
        else
            undefined

    getClause: -> @query.clauses.first()
    getChoices: ->
        @props.choices or @query.results.map (row) =>
            {id: row[0], "#{@props.labelField}": row[1]}

    onToggle: (isOpen) ->
        if isOpen and _.isEmpty(@props.choices)
            c = @getClause()
            c.value = ''
            @query.results.reload()
        @setState({isOpen})

    setModel: (model) ->
        @setState({isOpen: false, tempDisplayValue: false, requestInProgress: false})
        if @props.setSelection
            @props.setSelection(model, model: @model)
        else
            @model.set(@props.name, model)

    onChange: (value) ->
        if @props.multiSelect
            @setModel(value)
        else
            if _.isObject(value)
                model = if Lanes.u.isState(value) then value else new @query.model(value)
                if false is @props.fetchOnSelect
                    @setModel(model)
                else
                    model.fetch(@props.syncOptions).then(@setModel)
                @setState(isOpen: false, tempDisplayValue: value, requestInProgress: true)
            else
                if not @props.choices
                    c = @getClause()
                    return if c.value is value
                    c.value = value
                    @query.results.reload()
                @setState(isOpen: true)

    getMessages: ->
        loading = @query.results.requestInProgress
        emptyList: if loading then 'Loading …' else 'No records found'
        emptyFilter: 'No records found'

    isBusy: ->
        !!(@state.requestInProgress or @query.results.requestInProgress)

    renderDisplay: (props) ->
        value = @getValue()
        label = if _.isArray(value)
            _.toSentence( _.map(value, @props.labelField) )
        else if _.isObject(value)
            value[@props.labelField]
        else
            value
        <BS.FormControl.Static {...props}>
            {label}
        </BS.FormControl.Static>


    renderEdit: (props) ->
        type = if @props.multiSelect then 'Multiselect' else 'Combobox'
        Component = Lanes.Vendor.ReactWidgets[type]
        <Component
            ref="select"
            className={@props.className}
            open={@state.isOpen}
            onChange={@onChange}
            onToggle={@onToggle}
            data={@getChoices()}
            busy={@isBusy()}
            valueField="id"
            textField={@props.labelField}
            filter='startsWith'
            name={@props.name}
            messages={@getMessages()}
            onBlur={@onFieldInteraction}
            value={@getValue()}
            {...props}
        />
