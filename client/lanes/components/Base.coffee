class BaseComponent

    constructor: (options={})->
        super
        @access ||= this.calculate_access()

    namespace: "Components"

    session:
        access:
            type: 'string',
            values: ['read','write','none']

    derived:
        readOnly:  { deps: ['access'], fn:-> @access=='read' }
        writeAble: { deps: ['access'], fn:-> @access=='write' }

    readTemplate:  -> @renderTemplateMethod('template')
    writeTemplate: -> @renderTemplateMethod('template')
    emptyTemplate: -> '<span></span>'

    template: ->
        if this.writeAble
            this.writeTemplate()
        else if this.readOnly
            this.readTemplate()
        else
            this.emptyTemplate()

    calculate_access:->
        if ! @field_name || Lanes.Views.RenderContext.canWrite(@field_name)
            'write'
        else if Lanes.Views.RenderContext.canRead(@field_name)
            'read'
        else
            'none'


Lanes.Components.Base = Lanes.Views.Base.extend(BaseComponent)
