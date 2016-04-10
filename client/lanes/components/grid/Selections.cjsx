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



DEFAULTS =
    id: 'selected'
    query: false
    textAlign: 'center'
    fixedWidth: 90
    selectionDefault: true
    sortBy: (row, indx, all) ->
        false == this.xtraData(indx)?.selected

class Lanes.Components.Grid.Selections
    constructor: (options) ->
        _.extend(@, DEFAULTS)
        @onChange = options.onChange
        @choices = {}
        _.bindAll(@, 'onColumnClick')
        @component = _.partial(@component, _, @)

    onColumnClick: (ev, props) ->
        unless ev.target.tagName is 'INPUT'
            input = ev.target.querySelector('input')
            xd = props.query.results.xtraData(props.rowNum)
            xd.selected = input.checked = !input.checked
        @onChange?(props)
        ev.stopPropagation()

    component: (props, me) ->
        <CheckBox {...props} selections={me} />
