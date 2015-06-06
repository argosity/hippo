Lanes.React.Router = Lanes.Vendor.ReactRouter
Route = Lanes.React.Router.Route
Lanes.React.runRouter = (viewport) ->

    cntrl = Lanes.Extensions.controlling()

    defaultComponent = cntrl?.rootComponent?(viewport) ||
        Lanes.React.Root.DefaultComponentNotFound

    routes =
        <Route handler={Lanes.React.Root}>
            <Lanes.React.Router.DefaultRoute handler={defaultComponent}/>
            {Lanes.Extensions.routes()}
        </Route>

    Lanes.React.Router.run(routes, Lanes.React.Router.HistoryLocation, (Handler) ->
        React.render(<Handler viewport=viewport />, viewport.root)
    )
