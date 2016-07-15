class Lanes.Workspace.Layout extends Lanes.React.Component

    modelBindings:
        uistate:  -> Lanes.Workspace.Extension.uistate
        viewport: -> @context.viewport

    childContextTypes:
        uistate:  Lanes.PropTypes.State

    getChildContext: ->
        uistate: @uistate

    pageClasses: ->
        _.classnames( 'page-container', @uistate.screen_menu_size,
            {"popover_menu": @uistate.popover_menu}
        )

    componentWillMount: ->
        @uistate.set(@props)
        useBasename = Lanes.Vendor.BrowserHistory.useBasename
        history = useBasename(Lanes.Vendor.BrowserHistory.createHistory)({
            basename: Lanes.config.root_path
        })
        @historyStopListening = history.listen (location) ->
            Lanes.Screens.Definitions.setBrowserLocation(location)
        @setState({history})

    componentWillUnmount: -> @historyStopListening()

    render: ->
        <div className="layout">
            <LC.Modal {...@context.viewport.modalProps} />
            <Lanes.Workspace.Navbar history={@state.history} />
            <div className={@pageClasses()}>
                <Lanes.Workspace.ScreensMenu history={@state.history} />
                <Lanes.Workspace.ScreenView />
            </div>
        </div>
