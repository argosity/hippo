# ------------------------------------------------------------------ #
# The ModelChangeMonitor watches for changes on the                  #
# Model and remembers which attributes have been changed             #
# ------------------------------------------------------------------ #
class Lanes.Models.ChangeMonitor
    constructor: (@model)->
        @model.on('change', this.onChange, this)

    onChange: (record,options)->
        attrs = @model.changedAttributes()
        this.recordChanged( _.keys(attrs) )

    recordChanged: (names)->
        @_unsaved ||= {}
        for name in names
            this.recordChangedAttribute(name)

    changedAttributes: ->
        _.keys(@_unsaved)

    recordChangedAttribute:(name)->
        if @model._definition[name] && !@model._definition[name].session
            @_unsaved[ name ] = true

    reset: ->
        delete @_unsaved

    isDirty: ->
        !_.isEmpty(@_unsaved)
