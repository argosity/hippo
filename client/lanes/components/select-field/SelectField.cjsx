class Lanes.Components.SelectField extends Lanes.React.Component
    mixins: [ Lanes.Components.Form.FieldMixin ]

    getDefaultProps: ->
        labelField: 'name', idField: 'id'

    propTypes:
        collection: Lanes.PropTypes.Collection
        labelField: React.PropTypes.string
        getSelection: React.PropTypes.func
        setSelection: React.PropTypes.func

    dataObjects:
        collection: ->
            @props.collection || (
                @props.model?.associations.collectionFor(@props.name).fetch()
            )

    componentWillMount: ->
        @collection.ensureLoaded()

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

    getCurrentSelection: ->
        return @props.getSelection(@model) if @props.getSelection
        pk = @model.associations.pk(@props.name)
        selected = @collection.get( @model[pk] )
        return {} unless selected
        label = selected[@props.labelField]
        id = selected[@props.idField]
        label = String(label) if _.isObject(label)
        {id, label}

    renderDisplayValue: ->
        <span>{@getCurrentSelection().label}</span>

    _getChoices: ->
        if _.isFunction(@getChoices) then @getChoices() else
            labelField = @props.labelField
            @collection.map (model) ->
                {id: model.id, label: _.result(model, labelField)}

    renderEdit: (label) ->
        Component = if @props.multi
            Lanes.Vendor.ReactWidgets.Multiselect
        else
            Lanes.Vendor.ReactWidgets.Combobox
        props = _.omit(@props, 'label')
        select = <Component
            data={@_getChoices()}
            valueField="id"
            textField="label"
            onChange={@onChange}
            name={@props.name}
            value={@getCurrentSelection().id}
            {...props} />

        if @props.unstyled
            select
        else
            colProps = _.omit(@props, 'name')
            <BS.Col {...colProps}>
                <div className="form-group">
                    <label className="control-label">{label}</label>
                    <div className="value">
                        {select}
                    </div>
                </div>
            </BS.Col>
