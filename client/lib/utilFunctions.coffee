Lanes.emptyFn = ->

Lanes.fatal = (args...)->
    Lanes.warn(args...)
    throw new Error(args...)

Lanes.warn = (msg...)->
    console.warn(msg...) if console
    null

Lanes.log = (msg...)->
    console.log(msg...) if console
    null

distillTypes = (type, ns)->
    _.reduce( type.split( '.' ), ( ( memo, val )-> return if memo then memo[ val ] else null ),  ns )

# Can be called one of two ways:
# With ns being a string, which will attempt to deref it then deref name inside it
# or with ns being an object, which will dref name inside it
Lanes.getPath = ( name, ns='Lanes' ) ->
    return name unless _.isString(name)
    if _.isObject(ns)
        distillTypes(name,ns)
    else
        distillTypes(name,window) || distillTypes(name, distillTypes(ns, window))

Lanes.getModelPath = (scope,name)->
    [model..., field] = name.split('.')
    [ Lanes.getPath( model.join('.'), scope), field ]

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

    sprintfArray: (array, format)->
        _.map( array, (field)->
            _.sprintf( format, field )
        )

    evaluateFunction: (fn,args)->
        if this.isFunction(fn) then fn(args) else fn
})
