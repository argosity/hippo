Lanes.React.Mixins.FieldErrors = {


    componentWillMount: ->
        @getInvalidModel()?.maskInvalidFields?()

    getInvalidFieldName: ->
        @props.validity_attribute || @props.name

    getInvalidModel: ->
        @props.model || _.first _.values @data?.states

    isFieldValueInvalid: ->
        !!@fieldInvalidValueMessage()

    fieldInvalidValueMessage: ->
        # check needs to stay in sync with Lanes.React.Mixins.ReadEditingState.isEditingRecord
        return '' unless @props.editOnly or @context.recordDisplay == 'edit'

        @getInvalidModel()?.invalidMessageFor?(
            @getInvalidFieldName()
        )

    onFieldInteraction: ->
        @getInvalidModel()?.unmaskInvalidField?( @getInvalidFieldName() )
}
