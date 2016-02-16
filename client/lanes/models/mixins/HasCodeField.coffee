DEFAULT_INVALID = /[^A-Z0-9a-z]/

Lanes.Models.Mixins.HasCodeField = {


    included: (klass) ->
        klass::INVALID_CODE_CHARS ||= DEFAULT_INVALID

    initialize: ->
        this.on('change:code', this._cleanCodeAttr)

    _cleanCodeAttr: ->
        code = this.get('code')
        return unless code
        this.set(
            'code', code.toUpperCase().replace(@INVALID_CODE_CHARS, '')
        )

    visibleIdentifier: -> @code
}
