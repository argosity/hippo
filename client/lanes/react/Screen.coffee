Lanes.React.Screen = {

    defaultMixins: [
        Lanes.Vendor.ReactModelMixin
        Lanes.React.Mixins.Data
        Lanes.React.Mixins.Viewport
        Lanes.React.Mixins.Screen
        Lanes.React.Mixins.Access
        Lanes.React.Mixins.RelayEditingState
    ]

    extend: (klass) ->
        comp = Lanes.React.Component.extend(klass, @defaultMixins)
        klass::mixins.push _.uniq(klass::mixins.concat(this.defaultMixins))
        comp

}
