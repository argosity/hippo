Lanes.React.Mixins.Screen = {
    childContextTypes:
        screen: React.PropTypes.object

    listenNetworkEvents: true

    loadOrCreateModel: (options) ->
        if options.prop and @props[options.props]
            @props[options.props]
        else if options.attribute and @props.args?.length
            options.klass.fetch(_.extend( {}, options.syncOptions, {
                query: {"#{options.attribute}": @props.args[0]}
            }))
        else
            new options.klass

}
