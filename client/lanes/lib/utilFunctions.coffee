Lanes.emptyFn = ->

Lanes.fatal = (args...) ->
    Lanes.warn(args...)
    throw new Error(args...)

Lanes.warn = (msg...) ->
    return unless console
    if msg[0] instanceof Error
        console.warn(msg[0].stack)
    else console.warn(msg...)
    null

Lanes.log = (msg...) ->
    return unless console
    if msg[0] instanceof Error
        console.warn(msg[0].stack)
    else console.log(msg...)
    null

distillTypes = (type, ns) ->
    _.reduce( type.split( '.' ), ( ( memo, val ) -> return if memo then memo[ val ] else null ),  ns )

Lanes.u = {

    withReactContext: (newContext, fn) ->
        previousContext = Lanes.Vendor.ReactContext.current
        Lanes.Vendor.ReactContext.current = _.clone newContext
        ret = fn()
        Lanes.Vendor.ReactContext.current = previousContext
        ret

    makeComparatorUsing: (method) ->
        (a, b) -> Lanes.u.comparator(a[method], b[method])

    comparator: (a, b) ->
        if a < b then 1 else if a > b then -1 else 0

    objectForPath: (path) ->
        parts = path.replace(/\.js$/, '').split('/')
        last = null
        _.reduce( parts, (memo, val) ->
            last = memo[val] || memo[ _.classify(val) ] || last
        , Lanes)

    objectPath: (FILE) ->
        FILE.path

    path: (FILE) ->
        FILE.path.join("/")

    dirname: (FILE) ->
        FILE.path[0...FILE.path.length - 1].join("/")

    findObject:(name, subPath, file = FILE) ->
        if _.isObject(name)
            name
        else
            file.namespace[subPath]?[name] || Lanes[subPath]?[name] || Lanes.u.getPath(name)

    findRelative: (name, file) ->
        parts = _.map(file.path.slice(0, file.path.length - 1), (comp) ->
            _.classify(comp)
        )
        obj = _.reduce( parts, ( ( memo, val ) -> return if memo then memo[ val ] else null ), Lanes )
        obj?[name]

    isModel: (object) ->
        object instanceof Lanes.Models.BasicModel

    isCollection: (object) ->
        object instanceof Lanes.Models.Collection ||
            object instanceof Lanes.Models.BasicCollection ||
            object instanceof Lanes.Models.SubCollection

    isState: (object) ->
        object instanceof Lanes.Models.State

    # Can be called one of two ways:
    # With ns being a string, which will attempt to deref it then deref name inside it
    # or with ns being an object, which will dref name inside it
    getPath: ( name, ns = 'Lanes' ) ->
        return name unless _.isString(name)
        ns = "Lanes.#{ns}" if _.isString(ns) && !ns.match("Lanes")
        object = distillTypes(name, window)
        if ! object
            ns = if _.isObject(ns) then ns else distillTypes(ns, window)
            object = distillTypes(name, ns )
        object

    # Like underscore's results but allows passing
    # arguments to the function if it's called
    resultsFor:( scope, method, args... ) ->
        if _.isString(method)
            if _.isFunction(scope[method])
                scope[method].apply(scope, args)
            else
                scope[method]
        else if _.isFunction(method)
            method.apply(scope, args)
        else
            method

    closestEl: (el, name) ->
        # Traverse the DOM up with a while loop
        while ! _.dom(el).hasClass(name)
            # Increment the loop to the parent node
            el = el.parentNode
            return null unless el

        return el

    invokeOrReturn: (func, scope = this) ->
        if _.isFunction(func)
            func.apply(scope)
        else
            func


}

# Can be called one of two ways:
# With ns being a string, which will attempt to deref it then deref name inside it
# or with ns being an object, which will dref name inside it
# Lanes.getPath = ( name, ns='Lanes' ) ->
#     return name unless _.isString(name)
#     ns = "Lanes.#{ns}" if _.isString(ns) && !ns.match("Lanes")
#     distillTypes(name, window) || distillTypes(name, if _.isObject(ns) then ns else distillTypes(ns, window) )

# Lanes.findObject = (name, subPath, file=FILE) ->
#     if _.isObject(name)
#         name
#     else
#         file.namespace[subPath]?[name] || Lanes[subPath]?[name] || Lanes.getPath(name)

lcDash = (char, match, index) ->
    return ( if index == 0 then '' else '_' ) + char.toLowerCase()

_.mixin({
    dasherize: (str) ->
        _.trim(str).replace(/([A-Z])/g, lcDash).replace(/[-_\s]+/g, '-').toLowerCase()

    field2title: (field) ->
        _.titleize _.humanize field

    toSentence: (words = [], comma = ', ', nd = ' and ') ->
        last = words.pop()
        if last
            if words.length
                [words.join(comma), last].join(nd)
            else
                last
        else
            ''

})
