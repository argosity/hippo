Lanes.Components.Helpers = {

    modelLinkFields: (model) ->
        return (field) ->
            onChange: (ev) -> model[field] = ev.target.value
            value: _.result(model, field)


}
