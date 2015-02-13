moduleKeywords = ['extended', 'included', 'initialize']

class Lanes.lib.ModuleSupport
    @includeInto: (klass)->
        _.extend(klass,this)

    @include: (obj) ->
        special = this::extendedProperties || []
        if obj.initialize
            fn = @::initialize
            @::initialize = ->
                obj.initialize.apply(this, arguments)
                fn?.apply(this,arguments)

        for key, value of obj when key not in moduleKeywords
            # Assign properties to the prototype
            if key in special && @::[key]
                _.extend(@::[key], value)
            else
                @::[key] = value
        obj.included?.apply(@)
        this
