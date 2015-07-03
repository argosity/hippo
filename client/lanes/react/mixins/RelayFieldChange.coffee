Lanes.React.Mixins.RelayFieldChange = {

    linkData: (data, name) ->
        {
            onChange: (value) ->
                data[name] = value
            value: ->
                data[name]
        }

}
