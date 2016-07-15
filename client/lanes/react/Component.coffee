# createHelper = (component, name) ->
#     unless component.prototype[name]
#         Object.defineProperty(component.prototype, name,
#             configurable: true, enumerable: true
#             get: -> @data?.states[name]
#             set: (val) ->
#                 @data?.rebind("#{name}": val)
#         )

# extendComponent = (component) ->
#     names = _.keys(component.prototype.dataObjects).concat(['collection', 'model'])
#     for name in _.uniq(names)
#         createHelper(component, name)

Lanes.React.Component = {

    defaultMixins: [
        Lanes.Vendor.ReactModelMixin
        Lanes.React.Mixins.Data
        Lanes.React.Mixins.Viewport
        Lanes.React.Mixins.Component
    ]

    extend: (klass, mixins = @defaultMixins) ->
        klass::mixins ||= []
        klass::mixins = _.uniq(klass::mixins.concat(mixins))
        comp = React.createClass(klass.prototype)
#        extendComponent(comp)
        return Lanes.lib.HotReload?.remember(comp) or comp
}

Lanes.React.BaseComponent = {
    extend: (klass) ->
        comp = React.createClass(klass.prototype)
        return Lanes.lib.HotReload?.remember(comp) or comp
}
