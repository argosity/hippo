class CheckBox extends Lanes.React.BaseComponent
    d: -> @props.query.results.xtraData(@props.row)

    onChange: (ev) -> #, me, results, index) ->
        @d().selected = ev.target.checked
        @props.selections.onChange?(@props)
        @forceUpdate()

    render: ->
        selected = @d().selected
        selected = @props.selections.selectionDefault unless selected?
        <input type="checkbox" checked={selected} onChange={@onChange} />


class Lanes.Components.Grid.Selections
    id: 'selected'
    query: false
    textAlign: 'center'
    fixedWidth: 90
    selectionDefault: true
    sortBy: (row, indx, all) ->
        false == this.xtraData(indx)?.selected

    constructor: (options) ->
        @onChange = options.onChange
        @choices = {}
        _.bindAll(@, 'onColumnClick')
        @component = _.partial(@component, _, @)

    onColumnClick: (ev, {rowNum, field, query}) ->
        unless ev.target.tagName is 'INPUT'
            input = ev.target.querySelector('input')
            input.checked = !input.checked
            @select({target: input}, @, query.results, rowNum)
        ev.stopPropagation()

    component: (props, me) ->
        <CheckBox {...props} selections={me} />
