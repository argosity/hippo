Lanes.React.Root = React.createClass
    childContextTypes:
        viewport: Lanes.PropTypes.State.isRequired

    getChildContext: ->
        viewport: @props.viewport

    render: ->
        <div classNames="root">
            {this.props.children}
        </div>
