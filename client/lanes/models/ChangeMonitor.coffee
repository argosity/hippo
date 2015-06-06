# ------------------------------------------------------------------ #
# The ModelChangeMonitor watches for changes on the                  #
# Model and remembers which attributes have been changed             #
# ------------------------------------------------------------------ #

class Lanes.Models.ChangeMonitor
    constructor: (model) ->
        model.on('change', this.onChange, this)

    onChange: (record, options) ->
        attrs = record.changedAttributes()
        return if _.isEmpty(attrs)
        if attrs.isDirty == false
            delete @_unsaved
        else
            @_unsaved ||= {}
            this.recordChanges(record, _.keys(attrs))


    recordChanges: (record, names) ->
        # console.log "Change: #{names}"
        #console.log record.getAttributes(props:true, session: true)
        for name in names
            if name != record.idAttribute && record._definition[name] && !record._definition[name].session
                record.isDirty = true
                @_unsaved[ name ] = true

    changedAttributes: ->
        _.keys(@_unsaved)

    isDirty: ->
        !_.isEmpty(@_unsaved)
