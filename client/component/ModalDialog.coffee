class Lanes.Component.ModalDialog extends Lanes.Component.Base

    events:
        'hide.bs.modal': '_onHide'

    bindings:
        'ui.layout_size': { type:'class',selector:'.modal-dialog'}

    buttons:
        close: { label: 'Close', type: 'default', dismiss: true }

    session:
        dialog_title: 'string'

    initialize: (options)->
        super

    toggleShown: (show)->
        if show then this.show() else this.hide()

    template: (context)->
        tmpl = Lanes.Templates.find('modal', context.namespace)
        tmpl({
            size    : context.size  || 'lg'
            title   : context.title || context.dialog_title
            body    : context.renderTemplateMethod('bodyTemplate')
            buttons : context.buttons
        })

    hide:->
        this.$el.modal('hide')
        Lanes.Promise.resolve( this )

    show: ->
        this.render()
        this.$el.modal({ body: this.ui.viewport })
        this.notification = new Lanes.Deferred
        return this.notification.promise

    destroy: ->
        this.detach()

    _onHide: (ev)->
        this.notification.resolve(this)
