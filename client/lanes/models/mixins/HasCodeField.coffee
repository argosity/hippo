Lanes.Models.Mixins.HasCodeField = {

    INVALID: /[^A-Z0-9a-z]/

    included: (klass)->
        klass::INVALID_CODE_CHARS ||= Lanes.Models.mixins.Lanes.sCodeField.INVALID

    initialize: ->
        this.on('change:code', this.upcaseCode)

    upcaseCode: ->
        this.set('code', this.get('code').toUpperCase())
}
