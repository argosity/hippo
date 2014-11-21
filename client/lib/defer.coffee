Lanes.lib.defer = {
    defer: (fn, options={})->
        scope = options.scope || this
        _.delay( ->
            fn.apply(scope,options.arguments)
        ,options.delay||1)
}
