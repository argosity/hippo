class Lanes.Components.SelectField extends Lanes.React.Component
    mixins: [ Lanes.Components.Form.FieldMixin ]
    getDefaultProps: ->
        labelField: 'name', idField: 'id', displayLimit: 30, syncOptions: {}

    propTypes:
        collection:   Lanes.PropTypes.Collection
        model:        Lanes.PropTypes.Model
        labelField:   React.PropTypes.string
        getSelection: React.PropTypes.func
        setSelection: React.PropTypes.func
        displayLimit: React.PropTypes.number
        syncOptions:  React.PropTypes.any

    dataObjects:
        collection: ->
            @props.collection || (
                @props.model?.associations.collectionFor(@props.name, @props.model)
            )

    onChange: (selection) ->
        return unless  _.isString(selection)
        order = @props.queryOrder || { "#{@props.labelField}": 'desc' }
        options = { limit: @props.displayLimit, order}
        unless _.isEmpty(selection)
            options.query = {
                "#{@props.labelField}": { op: 'like', value: selection }
            }

        @collection.fetch(options)

    onSelect: (selections) ->
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
        if @model[@props.name].isNew()
            pk = @model.associations.pk(@props.name)
            id = @model[pk]
            if id
                @collection.getOrFetch(id,
                    _.extend({}, Lanes.u.invokeOrReturn(@props.syncOptions)))
            else
                null
        else
            @model[@props.name]

    getCurrentSelection: ->
        if @props.getSelection
            selection = @props.getSelection(@model)
            return selection if selection

        selected = @getCurrentModel()
        if selected
            {id: selected[@props.idField], label: selected[@props.labelField]}
        else
            {id: null, label: ''}


    renderDisplayValue: ->
        <span>{@getCurrentSelection()?.label}</span>

    _getChoices: ->
        selection = @getCurrentSelection()
        if @state.isOpen
            if _.isFunction(@getChoices) then @getChoices() else
                labelField = @props.labelField
                rows = @collection.map (model) ->
                    {id: model.id, label: _.result(model, labelField)}
                # # add the current selection if the rows from the collection don't include it
                # unless @collection.get( selection.id )
                #     rows.push(selection)
                if _.isEmpty(rows) then [@getCurrentSelection()] else rows
        else
            if selection then [selection] else []

    onToggle: (isOpen) ->
        @collection.fetch(
            _.extend(limit: @props.displayLimit, Lanes.u.invokeOrReturn(@props.syncOptions))
        ) if isOpen
        @setState({isOpen})

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
            onSelect={@onSelect}
            suggest={true}
            data={@_getChoices()}
            valueField="id"
            textField="label"
            onChange={@onChange}
            name={@props.name}
            {...props}
            value={@getCurrentSelection().id}
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
