class Lanes.Components.SelectField extends Lanes.React.Component
    mixins: [ Lanes.Components.Form.FieldMixin ]

    getDefaultProps: ->
        labelField: 'name'

    propTypes:
        collection: Lanes.PropTypes.Collection
        labelField: React.PropTypes.string
        getSelection: React.PropTypes.func
        setSelection: React.PropTypes.func

    getInitialState: ->
        collection = @props.collection || (
            @model.associations.collectionFor(@props.name).fetch()
        )
        {collection}

    getOptions: (input, cb) ->
        store = @state.collection
        labelField = @props.labelField

        store.ensureLoaded().then ->
            data = store.map (model) ->
                {value: model.id, label: _.result(model, labelField)}
            cb(null, options: data, complete: true)

    onChange: (label, selections) ->
        records = _.map selections, (selection) =>
            @state.collection.get(selection.value)

        value = if @props.multi then records else _.first(records)
        if @props.setSelection
            @props.setSelection(@model, value, selections)
        else
            @model.set(@props.name, value)
        true

    getCurrentSelection: ->
        return @props.getSelection(@model) if @props.getSelection

        pk = @model.associations.pk(@props.name)
        selected = @state.collection.get( @model[pk] )
        return {} unless selected
        value = selected[@props.labelField]
        id = selected[@props.idField]
        value = String(value) if _.isObject(value)
        {id, value}

    renderDisplayValue: ->
        <span>{@getCurrentSelection().value}</span>

    renderEdit: (label) ->
        select = <Lanes.Vendor.Select
            asyncOptions={@getOptions}
            onChange={@onChange}
            name={@props.name}
            value={@getCurrentSelection().value}
            {...@props} />

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
