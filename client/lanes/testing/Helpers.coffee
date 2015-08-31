Lanes.Test.renderComponent = (component, {props, options}) ->
    options ||= {}
    wrapper = React.createClass
        makePath: Lanes.emptyFn
        childContextTypes:
            router: React.PropTypes.func,
            routeDepth: React.PropTypes.number
        getChildContext: ->
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
    ->
        Lanes.Test.Utils.Simulate[name](@el, arguments...)
        return @

for name, func of Lanes.Test.Utils.Simulate
    Lanes.lib.Dom::[name] = wrap(name, func)

Lanes.lib.Dom::setValue = (value) ->
    @setAttribute('value', value).change()
