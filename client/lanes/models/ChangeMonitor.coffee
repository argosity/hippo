# ------------------------------------------------------------------ #
# The ModelChangeMonitor watches for changes on the                  #
# Model and remembers which attributes have been changed             #
# ------------------------------------------------------------------ #

class Lanes.Models.ChangeMonitor
    constructor: (model) ->
        model.on('change', this.onChange, this)
        @_unsaved = {}

    onChange: (record, options) ->
        attrs = record.changedAttributes()
        return if _.isEmpty(attrs)
        if attrs[record.idAttribute] and record.associations
            record.associations.onIdChange(record)
        if attrs.isDirty == false
            @_unsaved = {}
        else
            this.recordChanges(record, _.keys(attrs))

    reset: ->
        @_unsaved = {}

    recordChanges: (record, names) ->
        # console.log "Change: #{names}"
        # console.log record.getAttributes(props:true, session: true)
        for name in names
            if name != record.idAttribute && record._definition[name] && !record._definition[name].session
                record.isDirty = true
                @_unsaved[ name ] = true

    changedAttributes: ->
        _.keys(@_unsaved)

    isDirty: ->
        !_.isEmpty(@_unsaved)
