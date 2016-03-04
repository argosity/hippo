Lanes.React.Mixins.Screen = {

    childContextTypes:
        screen: React.PropTypes.object

    listenNetworkEvents: true

    loadOrCreateModel: (options) ->
        if options.prop and @props[options.prop]
            if options.syncOptions?.include
                @props[options.prop].withAssociations(options.syncOptions.include, options.syncOptions)
            @props[options.prop]
        else
            model = new options.klass
            if options.attribute and @props.args?.length
                model.fetch(_.extend( {}, options.syncOptions, {
                    query: {"#{options.attribute}": @props.args[0]}
                })).then => @state?.commands?.setModel(model)
            model

}
