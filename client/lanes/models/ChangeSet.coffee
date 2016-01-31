class Lanes.Models.ChangeSet extends Lanes.Models.Base

    constructor: ->
        super
        this.created_at = new Date

    session:
        update: 'object'
        by: 'object'
        created_at: { type: 'date', setOnce: true }

    derived:
        record: { deps: ['collection'], fn: -> @collection.parent }
        record_name: { deps: ['record'], fn: -> _.field2title @record.api_path() }
        fields: { deps: ['update'], fn: -> _.keys(@update) }
        displayed_fields: { deps:['fields'], fn: -> _.without(@fields, 'updated_by_id', 'updated_at') }
        displayed_changes:
            deps: ['displayed_fields'], fn: ->
                _.map @displayed_fields, (field) =>
                    c = @update[field]
                    { name: field, from: c[0], to: c[1] }

    value: ->
        set = {}
        for field, change of @update
            set[field] = if _.isArray(change) then _.last(change) else change
        set

class ChangeSetCollection extends Lanes.Models.BasicCollection

    model: Lanes.Models.ChangeSet

    constructor: (options) ->
        super([], options)

    comparator: (a, b) ->
        if b.created_at < a.created_at then -1 else if b.created_at > a.created_at then 1 else 0

Lanes.Models.ChangeSet.Collection = ChangeSetCollection
