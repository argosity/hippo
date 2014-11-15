Lanes.View.TimedHighlight = {

    cssClass: 'highlighted'
    displayLength: 2000
    current: null,

    cancelCurrent: ->
        return unless @current
        @current.el.removeClass(@cssClass)
        clearTimeout(@current.timeout)
        @current = null

    setTimeout: (timeout)->
        @current.timeout = _.delay( =>
            @current.el.trigger("highlight-hide")
            @cancelCurrent()
        ,timeout)

    move: (el)->
        return unless @current
        @current.el.removeClass(@cssClass)
        @current.el = el
        @current.el.addClass(@cssClass)

    on: (view, timeout=@displayLength)->
        view.$el.addClass(@cssClass)
        @current = { el: view.$el }
        @current.el.trigger("highlight-show")
        this.setTimeout(timeout)

    reset:(timeout)->
        clearTimeout(@current.timeout)
        this.setTimeout(timeout)

    remove: ->
        clearTimeout(@current.timeout)
        @current = null
}
