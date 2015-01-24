class Lanes.Components.PopOver extends Lanes.Components.Base

    domEvents:
        'hide.bs.popover': '_onHide'

    session:
        target: 'el'
        title: 'string'
        content: 'any'
        template: 'string'
        templateModels: 'object'
        placement: { type: 'string', default: "right" }
        destroyAfterHide: [ 'boolean', true, false ]

    derived:
        options:
            deps: ['title','content','template','templateModels'], fn:->
                content = if this.template then this.renderTemplate() else this.content
                { title: @title, content: content, html: true, placement: "auto #{@placement}" }

    renderTemplate: ->
        template = Lanes.Templates.find(this.template)
        if template
            template(this.templateModels)
        else
            Lanes.warn "PopOver Template #{this.template} was not found"

    initialize: (options)->
        template = Lanes.Templates.find('lanes/components/popover/template')({ className: options.className||'' })
        _.extend(options, this.options, {template: template, container: this.viewport?.root})
        this.target.popover(options).on("hide.bs.popover", _.bind(this._onHide, this) )
        this.show() if options.autoShow

    toggleShown: (show)->
        if show then this.show() else this.hide()

    show: ->
        this.target.popover('show')
        this.notification = new _.DeferredPromise
        return this.notification.promise

    destroy: ->
        this.target.popover('destroy')

    hide:->
        this.target.popover('hide')
        Lanes.Promise.resolve( this )
        this.destroy()

    _onHide: (ev)->
        this.notification.resolve(this)
        this.destroy() if this.destroyAfterHide
