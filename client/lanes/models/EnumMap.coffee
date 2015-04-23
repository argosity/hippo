# ------------------------------------------------------------------ #
# Handles Enum definitions.                                          #
# It creates a helper methods for each one                           #
# and contains utility functions to operate on them                  #
# ------------------------------------------------------------------ #
class Lanes.Models.EnumMap
    constructor: (@klass)->
        @enums = _.clone(@klass::enums)
        for enum_name, def of @enums
            this.defineAccessor(enum_name, _.invert(def))
            for name, id of def
                this.defineEnumHelper(enum_name, name, id)

    defineAccessor: (name, values)->
        Object.defineProperty(@klass.prototype, "#{name}_value", {
            get: ->
                values[this.get(name)]
        })

    defineEnumHelper: (enum_name, name, id)->
        Object.defineProperty(@klass.prototype, "is_#{name}", {
            set: Lanes.emptyFn
            get: ->
                this[enum_name] == id
        })
