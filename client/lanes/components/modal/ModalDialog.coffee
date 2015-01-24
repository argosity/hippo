class Lanes.Components.ModalDialog extends Lanes.Components.Base

    events:
        'hide.bs.modal': '_onHide'

    bindings:
        'viewport.layout_size': { type:'class',selector:'.modal-dialog'}
        'viewport.layout_size': { selector: '.modal', type: 'class' }

    buttons:
        close: { label: 'Close', type: 'default', dismiss: true }

    session:
        dialog_title: 'string'

    toggleShown: (show)->
        if show then this.show() else this.hide()

    template: ->
        tmpl = Lanes.Templates.find('lanes/components/modal/template')
        tmpl({
            size    : @size  || 'lg'
            title   : @title || context.dialog_title
            body    : this.renderTemplateMethod('bodyTemplate')
            buttons : @buttons
        })

    renderContextFree: ->
        this.replaceEl( this.renderTemplateMethod() );
        this

    hide:->
        this.$el.modal('hide')
        _.Promise.resolve( this )

    show: ->
        if this.rendered
            this.viewport.el.append(this.el)
            this.$el.modal('show')
        else
            this.render()
            this.$el.modal({ body: this.viewport.el })
        this.notification = new _.DeferredPromise
        return this.notification.promise

    destroy: ->
        this.detach()

    _onHide: (ev)->
        this.detach()
        this.notification.resolve(this)
