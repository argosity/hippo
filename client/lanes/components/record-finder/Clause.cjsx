class Field extends Lanes.React.Component
    render: ->
        return null unless @model.visible
        <div className="row">
            <input id={@model.id} type="radio" name="field" value={@model.id}
                checked={@model.selected}
                onChange={ => @model.selected = true }
            />
            <label htmlFor=@model.id>{@model.title}</label>
        </div>

class Operator extends Lanes.React.Component
    render: ->
        return null unless @model.valid
        <BS.Row>
            <input id={@model.id} type="radio" name="operator" value={@model.id}
                checked={@model.selected}
                onChange={ => @model.selected = true }
            />
            <label htmlFor=@model.id>{@model.name}</label>
        </BS.Row>

class Lanes.Components.RecordFinder.Clause extends Lanes.React.Component

    propsTypes:
        onAddClause: React.PropTypes.func.isRequired
        model: Lanes.PropTypes.State.isRequired

    setValue: (ev) ->
        @model.value = ev.target.value

    runQuery: -> @model.query.results.ensureLoaded()

    render: ->
        <BS.Row className="clause">
            <div className="col-xs-10">
                <div className="input-group">

                    <div className="input-group-btn">
                        <BS.DropdownButton id={@model.field.title} title={@model.description}>
                            <form>
                              <div className="col-xs-6">
                                <div className="fields">
                                    {@model.fields.map (f) ->
                                        <Field key=f.id model=f /> }
                                </div>
                              </div>
                              <div className="col-xs-6">
                                <div className="operators">
                                    {@model.operators.map (o) ->
                                        <Operator key=o.id model=o /> }
                                </div>
                              </div>
                            </form>
                        </BS.DropdownButton>
                    </div>
                    <input type="text"
                        value={@model.value}
                        onChange={@setValue}
                        className="form-control query-string"
                    />
                    <span className="input-group-btn">
                        <button type="button" onClick={=> @props.model.remove()}
                            className="btn btn-default del-clause">
                            <i className="icon icon-trash-o"></i>
                        </button>
                        <button type="button" onClick={@props.onAddClause}
                            className="btn btn-default add-clause">
                            <i className="icon icon-plus"></i>
                        </button>
                    </span>
                </div>
            </div>
            <div className="col-xs-2 action">
                <BS.Button className="run-query" block onClick={@runQuery}>
                    <i className="icon icon-search"></i><span> Search</span>
                </BS.Button>
            </div>
        </BS.Row>
