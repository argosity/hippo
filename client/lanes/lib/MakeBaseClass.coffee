mixinModules = (klass)->
    Lanes.lib.ModuleSupport.includeInto(klass)
    if klass::mixins
        klass.include(Lanes.u.getPath(mixin,klass::FILE?.namespace)) for mixin in klass::mixins

extendProperties = (parent,child)->
    child::extendedProperties = _.uniq(
        ( child::extendedProperties || [] ).concat(parent::extendedProperties)
    )
    for prop in child::extendedProperties
        if parent::[prop] && child::[prop]
            _.extend( child::[prop], parent::[prop] )


extendClass = (ampersand_base, parent, child)->
    child.__super__ = parent.prototype
    child.Derived = []
    parent.Derived.push(child)

    if parent::abstractClass && !_.has(child.prototype,'abstractClass')
        child::abstractClass = undefined

    extendProperties(parent, child) if parent::extendedProperties

    mixinModules(child)

    if child::abstractClass && !child.extended && parent.extended
        child.extended = parent.extended
    parent.extended(child) if _.isFunction(parent.extended)

    child = ampersand_base.extend.call(parent, child.prototype )

    child.extend = (klass)->
        extendClass( ampersand_base, child, klass )

    if child::abstractClass && !child.afterExtended && parent.afterExtended
        child.afterExtended = parent.afterExtended
    parent.afterExtended(child) if _.isFunction(parent.afterExtended)

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
