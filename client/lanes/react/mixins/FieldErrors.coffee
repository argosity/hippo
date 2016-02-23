Lanes.React.Mixins.FieldErrors = {

    mixins: [
        Lanes.React.Mixins.ReadEditingState
    ]

    getInvalidFieldName: ->
        @props.validity_attribute || @props.name

    getInvalidModel: ->
        @props.model || _.first _.values @data.states

    isFieldValueInvalid: ->
        !!@fieldInvalidValueMessage()

    fieldInvalidValueMessage: ->
        return '' unless @isEditingRecord()
        @getInvalidModel().invalidMessageFor(
            @getInvalidFieldName()
        )

    onFieldInteraction: ->
        @getInvalidModel().unmaskInvalidFields( @getInvalidFieldName() )
}
