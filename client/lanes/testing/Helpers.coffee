Lanes.Test.renderComponent = (component, props, options={}) ->

    wrapper = React.createClass
        makePath: Lanes.emptyFn
        childContextTypes:
            router: React.PropTypes.func,
            routeDepth: React.PropTypes.number
        getChildContext: ->
            router: Lanes.Test.stubRouterContext(options)
            routeDepth: 0
        render: ->
            React.createElement(component, props)

    wrapper = Lanes.Test.Utils.renderIntoDocument(
        React.createElement(wrapper)
    )

    Lanes.Test.Utils.findRenderedComponentWithType(wrapper, component)


Lanes.Test.Utils = Lanes.Vendor.ReactTestUtils

wrap = (name) ->
    -> Lanes.Test.Utils.Simulate[name](@el, arguments...)

for name, func of Lanes.Test.Utils.Simulate
    Lanes.lib.Dom::[name] = wrap(name, func)
