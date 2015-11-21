class Lanes.Components.Grid.Selections
    id: 'selected'
    query: false
    textAlign: 'center'
    fixedWidth: 80
    defaultClicked: true
    constructor: (options) ->
        @onChange = options.onChange
        @choices = {}
        _.bindAll(@, 'onColumnClick')
        @render = _.partial(@render, _, @)

    onColumnClick: (ev, {rowNum, field, query}) ->
        unless ev.target.tagName is 'INPUT'
            input = ev.target.querySelector('input')
            input.checked = !input.checked
            @select({target: input}, @, query.results, rowNum)
        ev.stopPropagation()

    select: (ev, me, results, index) ->
        x = results.xtraData(index)
        x.selected = ev.target.checked
        me.onChange?(index)

    render: (props, me) ->
        id = props.row[props.query.idIndex]
        x = props.query.results.xtraData(props.index)
        x.selected = me.defaultClicked unless x.selected?
        <input type="checkbox" defaultChecked={x.selected}
            onChange={_.partial(me.select, _, me, props.query.results, props.index)} />
