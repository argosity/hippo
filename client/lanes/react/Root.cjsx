Lanes.React.Root = React.createClass
    childContextTypes:
        viewport: Lanes.PropTypes.State.isRequired

    getChildContext: ->
        viewport: @props.route.viewport

    render: ->
        <div classNames="root">
            {this.props.children}
        </div>
