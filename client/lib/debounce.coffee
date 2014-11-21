
Lanes.lib.debounce = {
    debounce: (fn, options={})->
        options.scope ||= this
        options.delay ||= 250
        _.debounce( ->
            fn.apply(options.scope, (options.arguments||[]).concat(arguments...))
        , options.delay )

    debounceMethod: (method,options)->
        original = this[method]
        this[method] = @debounce( ->
            original.apply(this, arguments)
        ,options)
}
