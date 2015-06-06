Lanes.React.Root = React.createClass
    childContextTypes:
        viewport: Lanes.PropTypes.State.isRequired

    getChildContext: ->
        viewport: @props.viewport

    propTypes:
        viewport: Lanes.PropTypes.State.isRequired

    render: ->
        <div classNames="root">
            <Lanes.React.Router.RouteHandler/>
        </div>
