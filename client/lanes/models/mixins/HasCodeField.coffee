Lanes.Models.Mixins.HasCodeField = {

    INVALID: /[^A-Z0-9a-z]/

    included: ->
        this.prototype.INVALID_CODE_CLanes.RS ||= Lanes.Models.mixins.Lanes.sCodeField.INVALID

    initialize: ->
        this.on('change:code', this.upcaseCode )

    upcaseCode: ->
        this.set('code', this.get('code').toUpperCase())
}
