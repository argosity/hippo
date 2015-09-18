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
        if @props.setSelection
            @props.setSelection(@model, value, selections)
        else
            @model.set(@props.name, value)
        true

    getCurrentModel: ->
        value = @model[@props.name]
        return null unless value

        if not @props.multi and value.isNew()
            pk = @model.associations.pk(@props.name)
            id = @model[pk]
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
            if selected
                {id: selected[@props.idField], label: selected[@props.labelField]}
            else
                {id: null, label: ''}

    _getChoices: ->
        selection = @getCurrentSelection()
        if @state.isOpen
            labelField = @props.labelField
            rows = @collection.map (model) ->
                {id: model.id, label: _.result(model, labelField)}
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
            colProps = _.omit(@props, 'name')
            <BS.Col {...colProps}>
                <div className={@formGroupClasseNames()}>
                    <label className="control-label">{label}</label>
                    <div className="value">
                        {select}
                    </div>
                </div>
            </BS.Col>
