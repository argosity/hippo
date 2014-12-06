class Lanes.Views.FormBindings

    constructor: (@view, @keypath, @selector)->
        _.bindAll(this,'onFieldChange')
        @selector = "#{@selector} " if @selector
        @view.on( "change:el",          this.rebindForm,    this )
        @view.on( "change:#{@keypath}", this.rebindModel,   this )
        @view.on( "remove",             this.teardown,      this )
        this.rebindModel( @view, @model() )

    onFieldChange: (ev)->
        el = Lanes.$(ev.target);
        name = el.attr('name');
        m = this.model();
        return unless m.hasAttribute(name)
        val = el.val()

        el[0]._is_setting=true; m.set( name, val ); delete el[0]._is_setting
        msg = m.validateFieldChange(name,val)
        this.setError( el, msg )

    onAttributeUpdate: (model, opts={})->
        attributes = if opts.all then this.attributesFor(model) else model.changedAttributes()
        if attributes['errors'] && ! _.isEmpty(attributes['errors'])
            for name, message of attributes['errors']
                this.setError(Lanes.$(el),message) if el = this.getElement(name)
        for name, _ of attributes
            el = this.getElement(name)
            this.setElValue(Lanes.$(el),model.get(name)) if el && ! el._is_setting

    setElValue:  (el, value)->
        if el.attr('type')
            switch el.attr('type')
                when 'radio'
                    for input in Lanes.$(this.view.el).find("#{@selector}input[type=radio][name=#{el.attr('name')}]")
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
        @cached_fields ||= Lanes.$(@view.el).find("#{@selector}input, #{@selector}.ro-input.update")

    getElement: (name)->
        _.find( this.fields(), (i)->i.getAttribute('name') == name )

    setAllFields: ->
        this.onAttributeUpdate(this.model(), all: true)

    model: ->
        @cached_model ||= Lanes.getPath(@keypath, @view)

    rebindForm: (view, el)->
        input_selector = "#{@selector}input, #{@selector}select"
        if old_el = @view.changedAttributes()['el']
            Lanes.$(el).off("change", input_selector, this.onFieldChange )
        @cached_fields = null
        Lanes.$(el).on("change",input_selector, this.onFieldChange )

    rebindModel: (view, model)->
        this.clearErrors()
        if old_model = @view.changedAttributes()[@keypath]
            old_model.off( "change", this.onAttributeUpdate )
        if model
            this.onAttributeUpdate(model, { all: true } )
            @cached_model = null
            model.on('change', this.onAttributeUpdate, this )

    teardown: ->
        this.model().off( "change", this.onAttributeUpdate )
