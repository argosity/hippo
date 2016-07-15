class Lanes.Components.RecordFinder.Dialog extends Lanes.React.Component

    modelBindings:
        clauses: ->
            @props.query.clauses

    propTypes:
        query: Lanes.PropTypes.State.isRequired
        onRecordSelect: React.PropTypes.func.isRequired

    contextTypes:
        viewport: Lanes.PropTypes.State.isRequired

    warning: ->
        <BS.Alert bsStyle='warning'>
             <strong>{@model.lastServerMessage}</strong>
        </BS.Alert>

    onRecordSelect: (model) ->
        return unless model
        @props.query.loadModel(model).then @props.onRecordSelect
        _.delay( =>
            @onCancel()
        , 300)

    onCancel: ->
        @context.viewport.hideModal()

    addClause: ->
        @props.query.addNewClause()
    selectFirst: ->
        model = @props.query.results.modelAt(0)
        @onRecordSelect(model) if model

    onColumnSort: (field) ->
        clause = @clauses.last()
        clause.field = field
        _.dom(@, '.clause:last-child .query-string').focusAndSelect()

    render: ->
        <div className='record-finder-dialog row'>
            <div className="form-horizontal query-clauses">
            { for c in @clauses.models
                <LC.RecordFinder.Clause
                    key={c.cid} onEnter={@selectFirst}
                    onAddClause={@addClause} model=c /> }
            </div>
            <LC.Grid
                onColumnClick={@onColumnSort}
                query={@props.query} height=200 autoLoadQuery
                onSelectionChange=@onRecordSelect
            />
        </div>
