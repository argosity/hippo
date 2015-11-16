createHelper = (component, name) ->
    unless component.prototype[name]
        Object.defineProperty(component.prototype, name,
            configurable: true, enumerable: true
            get: -> @data?.states[name]
            set: (val) ->
                @data?.rebind("#{name}": val)
        )

extendComponent = (component) ->
    names = _.keys(component.prototype.dataObjects).concat(['collection', 'model'])
    for name in _.unique(names)
        createHelper(component, name)

Lanes.React.Component = {

    defaultMixins: [
        Lanes.React.Mixins.Data
        Lanes.React.Mixins.Viewport
        Lanes.React.Mixins.Component
    ]

    extend: (klass, mixins = @defaultMixins) ->
        klass::mixins ||= []
        klass::mixins = _.unique(klass::mixins.concat(mixins))
        comp = React.createClass(klass.prototype)
        extendComponent(comp)
        return Lanes.lib.HotReload.remember(comp)
}

Lanes.React.BaseComponent = {
    extend: (klass, mixins = @defaultMixins) ->
        comp = React.createClass(klass.prototype)
        return Lanes.lib.HotReload.remember(comp)
}
