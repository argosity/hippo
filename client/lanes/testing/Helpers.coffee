Lanes.Test.renderComponent = (component, args = {}) ->
    props   = args.props || {}
    options = args.options || {}
    wrapper = React.createClass
        makePath: Lanes.emptyFn
        childContextTypes:
            viewport: Lanes.PropTypes.State
            router: React.PropTypes.func
            routeDepth: React.PropTypes.number
        getChildContext: ->
            viewport: new Lanes.React.Viewport
            router: Lanes.Test.stubRouterContext(options.router)
            routeDepth: 0
        render: ->
            React.createElement(component, props)

    wrapper = Lanes.Test.Utils.renderIntoDocument(
        React.createElement(wrapper)
    )

    Lanes.Test.Utils.findRenderedComponentWithType(wrapper, component)



Lanes.Test.Utils = Lanes.Vendor.ReactTestUtils

wrap = (name) ->
    (options = {}) ->
        args = _.extend {target: @el}, options
        Lanes.Test.Utils.Simulate[name](@el, args)
        return @

for name, func of Lanes.Test.Utils.Simulate
    Lanes.lib.Dom::[name] = wrap(name, func)

Lanes.lib.Dom::setValue = (value) ->
    @value = value
    @change()
