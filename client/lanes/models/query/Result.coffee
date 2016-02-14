class Lanes.Models.Query.Result

    @extend: (other) ->
        _.extend(other.prototype, this.prototype)

    sortingFunction: ->
        field = @query.sortField
        return false unless field
        if _.isFunction field.sortBy then field.sortBy else false
