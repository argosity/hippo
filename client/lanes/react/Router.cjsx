Lanes.React.Router = Lanes.Vendor.ReactRouter

Route  = Lanes.React.Router.Route
Router = Lanes.React.Router.Router

Lanes.React.runRouter = (viewport) ->

    cntrl = Lanes.Extensions.controlling()

    defaultComponent = cntrl?.rootComponent?(viewport) ||
        Lanes.React.Root.DefaultComponentNotFound

    routes =
        <Router>
            <Route path="/" viewport={viewport} component={Lanes.React.Root}>
                <Lanes.React.Router.IndexRoute component={defaultComponent}/>
                {Lanes.Extensions.routes()}
            </Route>
        </Router>

    viewport.reactRoot = Lanes.Vendor.ReactDOM.render(routes, viewport.lanes)

    # Lanes.React.Router.run(routes, Lanes.React.Router.HistoryLocation, (Handler) ->
    #     React.render(<Handler viewport=viewport />, viewport.lanes)
    # )
