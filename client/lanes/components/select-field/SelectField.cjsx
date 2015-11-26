class Lanes.Components.SelectField extends Lanes.React.Component
    mixins: [ Lanes.Components.Form.FieldMixin ]

    propTypes:
        collection:   Lanes.PropTypes.Collection
        model:        Lanes.PropTypes.Model
        labelField:   React.PropTypes.string
        getSelection: React.PropTypes.func
        setSelection: React.PropTypes.func
        displayLimit: React.PropTypes.number
        syncOptions:  React.PropTypes.any
        fetchWhenOpen: React.PropTypes.bool
        allowFreeForm: React.PropTypes.bool
        includeBlankRow: React.PropTypes.bool
        displayFallback: React.PropTypes.string

    getDefaultProps: ->
        labelField: 'label', idField: 'id', displayLimit: 30, syncOptions: {}, fetchWhenOpen: true

    dataObjects:
        model: 'props'
        collection: ->
            @props.collection || (
                @props.model?.associations?.collectionFor(@props.name, @props.model)
            )

    onChange: (selections) ->
        selections = [selections] unless _.isArray(selections)
        records = _.map selections, (selection) =>
            @collection.get(selection.id)
        value = if @props.multi then records else _.first(records)
        if @props.allowFreeForm and not value
            value = _.first selections
        if @props.setSelection
            @props.setSelection(@model, value, selections)
        else
            @model.set(@props.name, value)
        true

    getCurrentModel: ->
        value = @model[@props.name]
        return null unless value
        if not @props.multi and Lanes.u.isModel(value) and not value.isNew()
            id = @model[@props.name].getId()
            if id
                @collection.getOrFetch(id,
                    _.extend({}, Lanes.u.invokeOrReturn(@props.syncOptions)))
            else
                null
        else
            value

    getCurrentSelection: ->
        if @props.getSelection
            selection = @props.getSelection(@model)
            return selection if selection
        selected = @getCurrentModel()
        if @props.multi
            selected
        else
            if selected and Lanes.u.isModel(selected)
                {id: selected[@props.idField], label: selected[@props.labelField]}
            else
                if @props.allowFreeForm
                    {id: selected, label: selected}
                else
                    @blankRecord()
    blankRecord: ->

        {id: null, label: @props.displayFallback || '---------'}

    _getChoices: ->
        selection = @getCurrentSelection()
        if @state.isOpen
            labelField = @props.labelField
            rows = @collection.map (model) ->
                {id: model.getId(), label: _.result(model, labelField)}
            if @props.includeBlankRow
                rows.unshift @blankRecord()
            if _.isEmpty(rows) then [@getCurrentSelection()] else rows
        else
            if selection then [selection] else []

    onToggle: (isOpen) ->
        @setState({isOpen})
        @collection.fetch(
            _.extend(limit: @props.displayLimit, Lanes.u.invokeOrReturn(@props.syncOptions))
        ) if isOpen and @props.fetchWhenOpen

    renderDisplayValue: ->
        value = if @props.multi
            _.toSentence _.pluck(@getCurrentSelection(), @props.labelField)
        else
            @getCurrentSelection()?.label
        <span>{value}</span>

    renderEdit: (label) ->
        Component = if @props.multi
            Lanes.Vendor.ReactWidgets.Multiselect
        else
            Lanes.Vendor.ReactWidgets.Combobox
        props = _.omit(@props, 'label')
        select = <Component
            ref="select"
            className={@props.className}
            open={@state.isOpen}
            onToggle={@onToggle}
            suggest={true}
            data={@_getChoices()}
            valueField="id"
            textField="label"
            onChange={@onChange}
            name={@props.name}
            {...props}
            value={@getCurrentSelection()}
            />


        if @props.unstyled
            select
        else
            <LC.FormGroup {...@props} className={@formGroupClassNames()} label={label}>
                {select}
            </LC.FormGroup>
