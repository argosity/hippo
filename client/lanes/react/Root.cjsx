Lanes.React.Root = React.createClass
    childContextTypes:
        viewport: Lanes.PropTypes.State.isRequired

    getChildContext: ->
        viewport: @props.viewport

    render: ->
        <div className="root">
            {this.props.children}
        </div>
