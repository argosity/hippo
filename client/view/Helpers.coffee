# "private" methods for the helpers
impl = {
    field: (name, options, writeable_input, readonly_input)->
        readonly_input = writeable_input if ! readonly_input
        o = this.field_options(name, options)
        if options.writable || Lanes.View.RenderContext.canRead(name)
            contents  = if options.unwrapped then "" else "<label class='skr #{o.widths}'><b>#{o.title}:</b>"
            contents += if options.writable || Lanes.View.RenderContext.canWrite(name)
                writeable_input
            else
                readonly_input
            contents += "</label>" unless options.unwrapped
        else
            contents = "<div class='#{o.widths}'></div>"
        this.markSafe(contents)

    template: (template,data)->
        this.markSafe( Lanes.Templates.find('view/_'+template)(data) )

    markSafe: (str)->
        result = new String(str)
        result.HTMLSafe = true
        result


    field_options: (name, options)->
        options.widths=[options.width] if options.width # convert singular widths into an array if present
        {
            widths: this.grid_widths(options.widths...)
            title:  _.escape( options.label || _.titleize(name) )
        }

    grid_width:(widths, type='')->
        last = widths[widths.length-1]
        widths.push(last) for i in [widths.length-1..4]
        ( "col-#{width}#{type}-#{widths[index]}" for index,width of ['xs','sm','md','lg'] ).join(' ')
}

Lanes.View.Helpers = {

    elid: -> 'id="' + _.uniqueId('v') + '"'

    toolbar: (options)->
        return impl.template( 'toolbar', options )

    button: (options)->
        if _.isString(options)
            options={ name: options, text: _.titleize(options) }
        _.defaults(options, { css: options.name, icon: "icon-#{options.name}" })
        if options.name == 'save' && !Lanes.View.RenderContext.canWrite(name)
            ""
        else
            impl.template('button', options )

    grid_offsets: (widths...)->
        impl.grid_width(widths,'-offset')

    grid_widths: (widths...)->
        impl.grid_width(widths);

    text_field: (name,options={})->
        impl.field(name, options,
            "<input type='text' name='#{name}'><span class='feedback'></span>"
            "<div class='ro-input update' name='#{name}'></div>"
        )

    subview: (name,options={})->
        definition = Lanes.View.RenderContext.view().subviews[name]
        selector = if definition.hook
            "data-hook='#{definition.hook}'"
        else
            "class='#{definition.selector}'"
        impl.field( name, options, "<div #{selector}></div>" )



}
