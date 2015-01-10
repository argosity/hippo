class BaseComponent

    constructor: (options={})->
        super
        @access ||= this.calculate_access()

    session:
        access:
            type: 'string',
            values: ['read','write','none']

    derived:
        readOnly:  { deps: ['access'], fn:-> @access=='read' }
        writeAble: { deps: ['access'], fn:-> @access=='write' }

    emptyTemplateName: -> this.writeTemplate()
    readTemplateName:  -> this.writeTemplate()
    writeTemplateName: -> 'lanes/views/empty-span'

    renderContextFree: ->
        tmpl = if this.writeAble
            'writeTemplate'
        else if this.readOnly
            'readTemplate'
        else
            'emptyTemplate'

        this.replaceEl( this.renderTemplateMethod(tmpl) );

    templatePrefix: -> this.FILE.extensionName.toLowerCase() + "/components/"

    calculate_access:->
        if ! @field_name || Lanes.Views.RenderContext.canWrite(@field_name)
            'write'
        else if Lanes.Views.RenderContext.canRead(@field_name)
            'read'
        else
            'none'

Lanes.Components.Base = Lanes.Views.Base.extend(BaseComponent)
