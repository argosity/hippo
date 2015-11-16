Lanes.Components.Grid.EditingMixin = {

    propTypes:
        #topOffset: React.PropTypes.number.isRequired
        rowIndex:  React.PropTypes.number.isRequired
#        rowHeight: React.PropTypes.number.isRequired
        onSave:    React.PropTypes.func.isRequired
        onCancel:  React.PropTypes.func.isRequired
        model:     Lanes.PropTypes.State.isRequired
        query:     Lanes.PropTypes.State.isRequired
        editors:   React.PropTypes.object
        beforeSave: React.PropTypes.func
        afterSave: React.PropTypes.func
        allowDelete: React.PropTypes.bool
        syncImmediatly: React.PropTypes.oneOfType([
            React.PropTypes.bool, React.PropTypes.func
        ])
    editorTypes:
        text: (props) ->
            <input type="text"
                name={props.field.id}
                value={props.value}
                onChange={_.partial(@onFieldChange, _, props.field)} />
        date: (props) ->
            <LC.DateTime inputOnly step={15}
                model={props.model} name={props.field.id}
                onChange={_.partial(@onDateFieldChange, _, props.field)} />

    listenNetworkEvents: true
    getDefaultProps: -> editors: {}
    #topOffset:       -> @props.topOffset + (@props.rowIndex * @props.rowHeight)

    renderControls: ->
        if @props.allowDelete
            deleteBtn =
                <button type="button" className="btn delete" onClick={@deleteRecord}>
                    <i className="icon icon-trash" />Delete
                </button>

        <div className="controls">
            <div className="buttons">
                <button type="button" className="btn cancel" onClick={@onCancel}>
                    <i className="icon icon-refresh" /> Cancel
                </button>
                {deleteBtn}
                <button type="button" className="btn save" onClick={@saveRecord}>
                    <i className="icon icon-save" />Save
                </button>
            </div>
        </div>

    getFieldValue: (field) ->
        if field.format
            field.format(@props.model[field.id], @props.model)
        else
            @props.model[field.id]

    onDateFieldChange: (date, field) ->
        @props.model[field.id] = date
    onFieldChange: (ev, field) ->
        @props.model[field.id] = ev.target.value

    renderFields: ->
        for field, index in @props.query.fields.models when field.visible
            @renderField(field, index)

    renderEditingBody: ->
        if _.isFunction(@renderBody)
            @renderBody()
        else
            <div className="editing-body">
                <div className="fields">
                    {@renderFields()}
                </div>
                {@renderControls()}
            </div>

    renderField: (field, index) ->
        control = if field.editable
            props = _.extend( {index, field, value: @getFieldValue(field)},
                _.pick(@props, 'model', 'query', 'rowIndex')
            )
            (@props.editors[field.id] || @editorTypes[field.type] || @editorTypes['text']).call(this, props)
        else
            <span>{@getFieldValue(field)}</span>

        <div key={field.id}
            style = {@props.cellStyles.styles[index]}
            className = {_.classnames('field', @props.cellStyles.classes[index])}
        >
            <label>{field.title}</label>
            {control}
        </div>

    onCancel: ->
        @props.onCancel(@props.model)

    shouldPerformSync: ->
        !!Lanes.u.resultsFor(@props, 'syncImmediatly', @props.model)

    saveRecord: ->
        return if false == @props.beforeSave?(@props.model, @props.rowIndex)
        if @shouldPerformSync()
            @props.model.save().then (model) =>
                @props.onSave(model)
                @props.afterEdit?(model, @props.rowIndex)
        else
            @props.onSave(@props.model)
            @props.afterEdit?(@props.model, @props.rowIndex)

    deleteRecord: ->
        if @shouldPerformSync()
            @props.model.destroy().then (model) => @props.onSave(model)
        else
            @props.onSave(@props.model)

}
