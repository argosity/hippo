class CheckBox extends Lanes.React.BaseComponent
    d: -> @props.query.results.xtraData(@props.row)

    onChange: (ev) ->
        @d().selected = ev.target.checked
        @props.selections.onChange?(@props)
        @forceUpdate()

    render: ->
        selected = @d().selected
        selected = @props.selections.selectionDefault unless selected?
        attrs = @props.selections.attributesGetter?(@props) || {}
        <input type="checkbox" checked={selected} onChange={@onChange} {...attrs} />



DEFAULTS =
    id: 'selected'
    query: false
    textAlign: 'center'
    fixedWidth: 90
    selectionDefault: true
    sortBy: (row, indx, all) ->
        false == this.xtraData(indx)?.selected

class Lanes.Components.Grid.Selections

    @setRow: (row, xd, selected) ->
        xd.selected = selected

    @isSelected: (row, xd, selected) ->
        !(xd && false == xd.selected)


    constructor: (options = {}) ->
        _.extend(@, DEFAULTS)
        _.extend(@, _.pick(options, 'onChange', 'attributesGetter'))
        @choices = {}
        _.bindAll(@, 'onColumnClick')
        @component = _.partial(@component, _, @)

    onColumnClick: (ev, props) ->
        unless ev.target.tagName is 'INPUT'
            input = ev.target.querySelector('input')
            unless input.disabled
                xd = props.query.results.xtraData(props.rowNum)
                xd.selected = input.checked = !input.checked
        @onChange?(props)
        ev.stopPropagation()

    component: (props, me) ->
        <CheckBox {...props} selections={me} />
