class Lanes.Components.Grid.Header extends Lanes.React.BaseComponent

    propTypes:
        query:      React.PropTypes.instanceOf(Lanes.Models.Query).isRequired
        cellStyles: React.PropTypes.object.isRequired

    renderHeader: (f, i) ->
        return unless @props.cellStyles.props[i]
        # style = {flex: f.flex, flexBasis: f.flexBasis}
        # classes = _.classnames( 'c', f.textAlign)
        <div key={i} {...@props.cellStyles.props[i]} >
            {f.title}
        </div>

    render: ->
        columns = @props.query.fields.map @renderHeader

        <div className="header">
            {columns}
        </div>
