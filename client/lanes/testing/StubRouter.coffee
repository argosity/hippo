METHODS = [
    'makePath'
    'makeHref'
    'transitionTo'
    'replaceWith'
    'goBack'
    'getCurrentPath'
    'getCurrentRoutes'
    'getCurrentPathname'
    'getCurrentParams'
    'getCurrentQuery'
    'isActive'

    'setRouteComponentAtDepth'
]

Lanes.Test.stubRouterContext = (options={}) ->
    RouterStub = Lanes.emptyFn

    for method in METHODS
        RouterStub[method] = options[method] || -> {}
    RouterStub.getRouteAtDepth = (depth) ->
        if options.routeHandler
            handler: options.routeHandler
        else null

    RouterStub
