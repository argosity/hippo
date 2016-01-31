Lanes.React.Mixins.Screen = {
    childContextTypes:
        screen: React.PropTypes.object

    listenNetworkEvents: true

    loadOrCreateModel: (options) ->
        if options.prop and @props[options.prop]
            @props[options.prop]
        else
            model = new options.klass
            if options.attribute and @props.args?.length
                model.fetch(_.extend( {}, options.syncOptions, {
                    query: {"#{options.attribute}": @props.args[0]}
                }))
            model


}
