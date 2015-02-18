# ------------------------------------------------------------------ #
# The ModelChangeMonitor watches for changes on the                  #
# Model and remembers which attributes have been changed             #
# ------------------------------------------------------------------ #

class Lanes.Models.ChangeMonitor
    constructor: (model)->
        model.on('change', this.onChange, this)
        model.on('change:isDirty', this.onDirtyChange, this)

    onChange: (record,options)->
        attrs = record.changedAttributes()
        return if _.isEmpty(attrs)
        @_unsaved ||= {}
        this.recordChanges(record,_.keys(attrs))


    recordChanges: (record,names) ->
        for name in names
            if name != record.idAttribute && record._definition[name] && !record._definition[name].session
                record.isDirty = true
                @_unsaved[ name ] = true

    onDirtyChange: (record,isDirty)->
        delete @_unsaved if !isDirty

    changedAttributes: ->
        _.keys(@_unsaved)


    isDirty: ->
        !_.isEmpty(@_unsaved)
