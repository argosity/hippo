Lanes.Models.Mixins.TrackRemovals = {

    initialize: ->
        @on('remove', (model) ->
            @_removedModelIds ||= []
            @_removedModelIds.push model.getId()
        )

    getRemovedModelIds: ->
        @_removedModelIds || []

    clearRemovedModelIds: ->
        delete @_removedModelIds

    hasRemovedModels: ->
        !!@_removedModelIds
}
