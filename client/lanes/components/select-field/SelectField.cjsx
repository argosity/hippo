class Lanes.Components.SelectField extends Lanes.React.Component
    mixins: [ Lanes.Components.Form.FieldMixin ]
    getDefaultProps: ->
        labelField: 'name', idField: 'id', displayLimit: 30

    propTypes:
        collection: Lanes.PropTypes.Collection
        labelField: React.PropTypes.string
        getSelection: React.PropTypes.func
        setSelection: React.PropTypes.func
        displayLimit: React.PropTypes.number

    dataObjects:
        collection: ->
            @props.collection || (
                @props.model?.associations.collectionFor(@props.name)
            )

    onChange: (selection) ->
        return unless  _.isString(selection)
        options = { limit: @props.displayLimit, order: { "#{@props.labelField}": 'desc' } }
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
        @model.associations.getModelFromCollection(@model, @props.name, @collection)

    getCurrentSelection: ->
        return @props.getSelection(@model) if @props.getSelection

        selected = @getCurrentModel()

        if selected
            {id: selected[@props.idField], label: selected[@props.labelField]}
        else
            {id: null, label: ''}


    renderDisplayValue: ->
        <span>{@getCurrentSelection()?.label}</span>

    _getChoices: ->
        if @state.isOpen
            if _.isFunction(@getChoices) then @getChoices() else
                labelField = @props.labelField
                @collection.map (model) ->
                    {id: model.id, label: _.result(model, labelField)}
        else
            selection = @getCurrentSelection()
            if selection then [selection] else []

    onToggle: (isOpen) ->
        @collection.fetch(limit: @props.displayLimit) if isOpen
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
