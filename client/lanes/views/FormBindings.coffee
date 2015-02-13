class Lanes.Views.FormBindings

    constructor: (@view, config={})->
        _.bindAll(this,'onFieldChange')
        @selector = if config.selector then "#{config.selector} " else ""
        @view.on( "change:el",     this.rebindForm,    this )
        @view.on( "change:model",  this.rebindModel,   this )
        @view.on( "remove",        this.teardown,      this )
        this.rebindModel( @view, @view.model )

    onFieldChange: (ev)->
        el = Lanes.$(ev.target)
        name = el.attr('name')
        return unless @view.model?.hasAttribute(name)
        val = el.val()
        unless false == this.view.trigger("update:#{val}", val)
            el[0].binding_is_setting=true; @view.model.setFromView(name, val); delete el[0].binding_is_setting
        msg = @view.model.checkValid(name,val)
        this.setError( el, msg )
        return true

    onAttributeUpdate: (model, opts={})->
        attributes = if opts.all then this.attributesFor(model) else model.changedAttributes()
        if attributes['errors'] && ! _.isEmpty(attributes['errors'])
            for name, message of attributes['errors']
                this.setError(Lanes.$(el),message) if el = this.getElement(name)
        for name, _val of attributes
            el = this.getElement(name)
            this.setElValue(Lanes.$(el),model.get(name)) if el && ! el.binding_is_setting
        return true

    setElValue:  (el, value)->
        if el.attr('type')
            switch el.attr('type')
                when 'radio'
                    selector="#{@selector}input[type=radio][name=#{el.attr('name')}]"
                    for input in Lanes.$(this.view.el).find(selector)
                        input.checked = input.value == value
                when 'checkbox'
                     el.prop('checked', !!value)
                when 'break'
                    file
                else
                    el.val(value)
        else if el.is('input') || el.is('select') || el.is('textarea')
            el.val(value ||  ( if value == 0 then '0' else '') )
        else
            el.text(value || ( if value == 0 then '0' else '') )

    clearErrors: ->
        Lanes.$(this.view.el).find(
            this.selector + "input ~ .feedback.error, " +
            this.selector + ".ro-input.update ~ .feedback.error"
        ).removeClass('error')

    setError: (el, message)->
        return unless placeholder = el.siblings('.feedback')
        if message
            placeholder.addClass('error')
            placeholder.attr('data-tooltip-message', message)
        else
            placeholder.removeClass('error')

    attributesFor: (model)->
        attrs = {}
        for name,val of model._definition
            attrs[name]=val #if ! val.session
        attrs

    fields: ->
        @cached_fields ||= @view.el?.querySelectorAll("#{@selector}input, #{@selector}.ro-input.update")

    getElement: (name)->
        return unless fields = this.fields()
        for field in fields
            return field if field.getAttribute('name') == name
        null

    setAllFields: ->
        this.onAttributeUpdate(@view.model, all: true)

    rebindForm: (view, el)->
        input_selector = "#{@selector}input, #{@selector}select"
        if old_el = @view.changedAttributes()['el']
            Lanes.$(el).off("change", input_selector, this.onFieldChange )
        @cached_fields = null
        if @view.model
            this.setAllFields()
        @view.$el.on("change", input_selector, this.onFieldChange)

    rebindModel: (view, model)->
        this.clearErrors()
        if old_model = @view.changedAttributes()['model']
            old_model.off( "change", this.onAttributeUpdate )
        if model
            this.onAttributeUpdate(model, { all: true } )
            @cached_model = null
            model.on('change', this.onAttributeUpdate, this )

    teardown: ->
        @view.model?.off( "change", this.onAttributeUpdate )
