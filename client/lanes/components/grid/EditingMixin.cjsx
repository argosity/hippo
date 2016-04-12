Lanes.Components.Grid.EditingMixin = {

    propTypes:
        rowIndex:  React.PropTypes.number.isRequired
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
            <input type="text" {...props}
                onChange={_.partial(@onFieldChange, _, props.field)} />
        bigdec: (props) ->
            <LC.NumberInput unstyled {...props} />
        date: (props) ->
            <LC.DateTime {...props} inputOnly step={15}
                onChange={_.partial(@onDateFieldChange, _, props.field)} />

    displayTypes:
        bigdec: (props) ->
            <span>{props.value.toFixed(2)}</span>
        text: (props) ->
            <span>{props.value}</span>

    listenNetworkEvents: true
    getDefaultProps: -> editors: {}
    componentDidMount: ->
        _.dom(@).qs('input').focusAndSelect()

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

    renderEditValue: (props) ->
        ( @props.editors[props.field.id] ||
          @editorTypes[props.field.type] ||
          @editorTypes['text']
        ).call(this, props)

    renderDisplayValue: (props) ->
        ( @displayTypes[props.field.type] || @displayTypes['text'] ).call(this, props)

    renderField: (field, index) ->
        props = _.extend( {
            index, field, props: @props, name: field.id, value: @getFieldValue(field)
        }, _.pick(@props, 'model', 'query', 'rowIndex') )
        control = if field.editable then @renderEditValue(props) else
            @renderDisplayValue(props)

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
            @props.model.destroy().then (model) =>
                @props.onSave(model, true)
        else
            @props.onSave(@props.model, true)

}
