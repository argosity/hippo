Lanes.emptyFn = ->

Lanes.fatal = (args...)->
    Lanes.warn(args...)
    throw new Error(args...)

Lanes.warn = (msg...)->
    return unless console
    console.warn(msg...)
    if msg[0] instanceof Error
        console.warn(msg[0].stack)
    else console.warn(msg...)
    null

Lanes.log = (msg...)->
    return unless console
    if msg[0] instanceof Error
        console.warn(msg[0].stack)
    else console.log(msg...)
    null

distillTypes = (type, ns)->
    _.reduce( type.split( '.' ), ( ( memo, val )-> return if memo then memo[ val ] else null ),  ns )

# Can be called one of two ways:
# With ns being a string, which will attempt to deref it then deref name inside it
# or with ns being an object, which will dref name inside it
Lanes.getPath = ( name, ns='Lanes' ) ->
    return name unless _.isString(name)
    ns = "Lanes.#{ns}" if _.isString(ns) && !ns.match("Lanes")
    if _.isObject(ns)
        distillTypes(name,ns) || distillTypes(name, Lanes)
    else
        distillTypes(name,window) || distillTypes(name, distillTypes(ns, window))

_.mixin({

    toSentence: (words=[], comma=', ', nd=' and ')->
        last = words.pop()
        if last
            if words.length
                [words.join(comma),last].join(nd)
            else
                last
        else
            ''
    evaluateFunction: (fn,args)->
        if this.isFunction(fn) then fn(args) else fn
})
