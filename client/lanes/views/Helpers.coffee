# "private" methods for the helpers
impl = {
    field: (name, options, writeable_input, readonly_input)->
        readonly_input = writeable_input if ! readonly_input
        o = this.field_options(name, options)
        if options.writable || Lanes.Views.RenderContext.canRead(name)
            contents  = if options.unwrapped then "" else "<label class='skr #{o.widths}'><b>#{o.title}:</b>"
            contents += if options.writable || Lanes.Views.RenderContext.canWrite(name)
                writeable_input
            else
                readonly_input
            contents += "</label>" unless options.unwrapped
        else
            contents = "<div class='#{o.widths}'></div>"
        this.markSafe(contents)

    template: (template,data)->
        this.markSafe( Lanes.Templates.find('lanes/views/_'+template)(data) )

    markSafe: (str)->
        result = new String(str)
        result.HTMLSafe = true
        result

    field_options: (name, options)->
        options.widths = [options.width] if options.width
        options.widths = this.grid_widths(options.widths) if options.widths
        options.title  =  _.escape( options.label || _.titleize(name) )
        options

    grid_widths:(widths, type='')->
        last = widths[widths.length-1]
        widths.push(last) for i in [widths.length-1..4]
        ( "col-#{width}#{type}-#{widths[index]}" for index,width of ['xs','sm','md','lg'] ).join(' ')
}

Lanes.Views.Helpers = {

    elid: -> 'id="' + _.uniqueId('v') + '"'

    toolbar: (options)->
        return impl.template( 'toolbar', options )

    button: (options)->
        if _.isString(options)
            options={ name: options, text: _.titleize(options) }
        _.defaults(options, { css: options.name, icon: "icon-#{options.name}" })
        if options.name == 'save' && !Lanes.Views.RenderContext.canWrite(name)
            ""
        else
            impl.template('button', options )

    grid_offsets: (widths...)->
        impl.grid_widths(widths,'-offset')

    grid_widths: (widths...)->
        impl.grid_widths(widths);

    text_field: (name,options={})->
        impl.field(name, options,
            "<input type='#{options.type || 'text'}' name='#{name}'><span class='feedback'></span>"
            "<div class='ro-input update' name='#{name}'></div>"
        )

    subview: (name,options={})->
        definition = Lanes.Views.RenderContext.view().subviews[name]
        selector = if definition.hook
            "data-hook='#{definition.hook}'"
        else
            "class='#{definition.selector}'"
        impl.field( name, options, "<div #{selector}></div>" )



}
