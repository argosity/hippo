class Lanes.Components.SelectField extends Lanes.React.Component
    mixins: [ Lanes.Components.Form.FieldMixin ]

    getDefaultProps: ->
        labelField: 'name'

    propTypes:
        collection: Lanes.PropTypes.Collection
        labelField: React.PropTypes.string

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

    onChange: (val) ->
        val = @state.collection.get(val) if val
        @model.set(@props.name, val)
        true

    stringValue: ->
        pk = @model.associations.pk(@props.name)
        selected = @state.collection.get( @model[pk] )
        value = selected?[@props.labelField]
        value = String(value) if _.isObject(value)
        value

    renderDisplayValue: ->
        <span>{@stringValue()}</span>

    renderEdit: (label) ->
        colProps = _.omit(@props, 'name')
        <BS.Col {...colProps}>
            <div className="form-group">
                <label className="control-label">{label}</label>
                <div className="value">
                    <Lanes.Vendor.Select
                        asyncOptions={@getOptions}
                        onChange={@onChange}
                        name={@props.name}
                        value={@stringValue()}
                        {...@props} />
                </div>
            </div>
        </BS.Col>
