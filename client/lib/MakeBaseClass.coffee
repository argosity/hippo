FUNC_NAME_REGEX = /function\s+([^\s\(]+)/

addMissingFunctionName = (klass)->
    return if klass.name
    Object.defineProperty( klass, 'name', {
        get: ->
            this._name_cache_ ||= (
                results = FUNC_NAME_REGEX.exec((this).toString())
                if (results && results.length) then results[1] else ""
            )
        set: (value)->
            return {}
    })

mixinModules = (klass)->
    Lanes.lib.ModuleSupport.includeInto(klass)
    if klass::mixins
        klass.include(Lanes.getPath(mixin)) for mixin in klass::mixins

extendClass = (ampersand_base, parent, child)->
    child.__super__ = parent.prototype
    child.Derived = []
    parent.Derived.push(child)
    for prop in parent::extended_properties || []
        if parent::[prop] && child::[prop]
            _.extend( child::[prop], parent::[prop] )

    mixinModules(child)

    parent.extended(child) if _.isFunction(parent.extended)

    child = ampersand_base.extend.call(parent, child.prototype )

    child.extend = (klass)->
        extendClass( ampersand_base, child, klass )

    parent.after_extended(child) if _.isFunction(parent.after_extended)
    addMissingFunctionName(child)
    child


createExtendsChain = ( ampersand_base, base )->
    return (klass)->
        extendClass( ampersand_base, this, klass )
    base.__super__ = ampersand_base.prototype
    base



Lanes.lib.MakeBaseClass = ( ampersand_base, base )->
    base = ampersand_base.extend( base.prototype )
    mixinModules(base)
    base.extend = createExtendsChain( ampersand_base, base )
    base.Derived = []
    base
