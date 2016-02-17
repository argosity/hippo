class Lanes.Components.Grid.Header extends Lanes.React.BaseComponent

    propTypes:
        query:      React.PropTypes.instanceOf(Lanes.Models.Query).isRequired
        cellStyles: React.PropTypes.object.isRequired

    onColumnClick: (f) ->
        @props.query.setSortField(f)

        @forceUpdate()

    renderHeader: (f, i) ->
        return unless @props.cellStyles.props[i]
        sorted = f.sortable and @props.query.sortField is f
        classNames = _.classnames(
            sort:  f.sortable
            asc:   sorted and @props.query.sortAscending
            desc:  sorted and not @props.query.sortAscending
            @props.cellStyles.props[i].className
        )
        <div key={i}
            {...@props.cellStyles.props[i]}
            onClick={_.partial(@onColumnClick, f)}
            className={classNames}
        >
            <span className='l'>{f.title}</span>
        </div>

    render: ->
        columns = @props.query.fields.map @renderHeader

        <div className="header">
            {columns}
        </div>
