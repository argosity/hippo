Lanes.Components.Grid.EditingMixin = {

    propTypes:
        grid:      React.PropTypes.object.isRequired
        topOffset: React.PropTypes.number.isRequired
        rowIndex:  React.PropTypes.number.isRequired
        rowHeight: React.PropTypes.number.isRequired
        onSave:    React.PropTypes.func.isRequired
        onCancel:  React.PropTypes.func.isRequired
        model:     Lanes.PropTypes.State.isRequired
        query:     Lanes.PropTypes.State.isRequired
        editors:   React.PropTypes.object
        allowDelete: React.PropTypes.bool
        syncImmediatly: React.PropTypes.oneOfType([
            React.PropTypes.bool, React.PropTypes.func
        ])

    listenNetworkEvents: true
    getDefaultProps: -> editors: {}
    topOffset:       -> @props.topOffset + (@props.rowIndex * @props.rowHeight)

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

    getFieldValue: (column) ->
        if column.format
            column.format(@props.model[column.id], @props.model)
        else
            @props.model[column.id]

    onFieldChange: (column, ev) ->
        @props.model[column.id] = ev.target.value

    renderFields: ->
        @props.query.fields.visible.map @renderField

    renderEditingBody: ->
        if _.isFunction(@renderBody)
            @renderBody()
        else
            <div className="body">
                <div className="fields">
                    {@renderFields()}
                </div>
                {@renderControls()}
            </div>

    renderField: (column, index) ->
        return null unless column.visible
        control = if @props.editors[column.id]
            @props.editors[column.id](model: @props.model)
        else
            <input type="text"
                style={textAlign: column.textAlign}
                value={@getFieldValue(column)}
                onChange={_.partial(@onFieldChange, column)} />
        <div key={column.id} style={flex: column.flex} className="field">
            <label>{column.title}</label>
            {control}
        </div>

    onCancel: ->
        @props.onCancel(@props.model)

    shouldPerformSync: ->
        !!Lanes.u.resultsFor(@props, 'syncImmediatly', @props.model)

    saveRecord: ->
        if @shouldPerformSync()
            @props.model.save().then (model) => @props.onSave(model)
        else
            @props.onSave(@props.model)

    deleteRecord: ->
        if @shouldPerformSync()
            @props.model.destroy().then (model) => @props.onSave(model)
        else
            @props.onSave(@props.model)

}
