class Lanes.Data.ChangeSet extends Lanes.Data.Model

    constructor: ->
        super
        this.created_at = new Date
        this.updateTimeAgo()

    session:
        update: 'object'
        record: 'model'
        time_ago: 'string'
        created_at: { type: 'date', setOnce: true }

    derived:
        fields: { deps: ['update'], fn: -> _.keys(@update) }
        displayed_fields: { deps:['fields'], fn: -> _.without(@fields, 'updated_by_id', 'updated_at') }

    changeFor:(field)->
        change = @update[field] || []
        { from: change[0], to: change[1] }

    associations:
        by: { model: "User" }

    value: ->
        set={}
        for field, change of @update
            set[field] = change[1]
        set

    updateTimeAgo: ->
        @time_ago = Lanes.Vendor.Moment( @created_at ).fromNow()


class Lanes.Data.ChangeSetCollection extends Lanes.Data.BasicCollection

    model: Lanes.Data.ChangeSet

    constructor: (options)->
        super([],options)
        this.on("add", this.onAdd, this )

    onAdd: (change)->
        record = this.parent
        while record
            record.trigger('remote-update', record, change);
            record = record.parent

    comparator: (a,b)->
        if b.created_at < a.created_at then -1 else if b.created_at > a.created_at then 1 else 0
