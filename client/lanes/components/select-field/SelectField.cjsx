class Lanes.Components.SelectField extends Lanes.React.Component
    mixins: [ Lanes.Components.Form.FieldMixin ]

    propTypes:
        choices: React.PropTypes.arrayOf(
            React.PropTypes.shape({
                id: React.PropTypes.any
                label: React.PropTypes.string
            })
        )
        model:        Lanes.PropTypes.Model
        labelField:   React.PropTypes.string
        getSelection: React.PropTypes.func
        setSelection: React.PropTypes.func
        displayLimit: React.PropTypes.number
        syncOptions:  React.PropTypes.object
        multiSelect:  React.PropTypes.bool
        fetchWhenOpen: React.PropTypes.bool
        allowFreeForm: React.PropTypes.bool
        includeBlankRow: React.PropTypes.bool
        displayFallback: React.PropTypes.string

    getDefaultProps: ->
        labelField: 'code', idField: 'id'

    dataObjects:
        query: ->
            src = @props.queryModel or
                @props.model.associations?.collectionFor(@props.name).model
            query = new Lanes.Models.Query({
                syncOptions: Lanes.Models.Query.mergedSyncOptions(@props.syncOptions)
                src: src
                fields: [
                    {id: (@props.model?.idAttribute or 'id'), visible: false},
                    @props.labelField
                ]
            })

    renderDisplayValue: ->
        value = @getValue()?[@props.labelField]
        <span>{value}</span>

    getValue: ->
        return undefined if @state.isOpen and not @props.multiSelect
        return @state.tempDisplayValue if @state.tempDisplayValue
        model = @props.getSelection?(@model, @props) or @model?[@props.name]
        return undefined unless model
        return model if @props.multiSelect
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

    renderEdit: (label) ->
        props = _.omit(@props, 'label')
        Component = Lanes.Vendor.ReactWidgets[if @props.multiSelect then 'Multiselect' else 'Combobox']
        select = <Component
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


        if @props.unstyled
            select
        else
            <LC.FormGroup
                {...@props}
                className={@formGroupClassNames()}
                label={@getLabelValue()}
            >
                {select}
            </LC.FormGroup>
