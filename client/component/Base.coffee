class BaseComponent

    constructor: (options={})->
        super
        @access ||= this.calculate_access()

    namespace: "Component"

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

    template: (scope)->
        if scope.writeAble
            scope.writeTemplate()
        else if scope.readOnly
            scope.readTemplate()
        else
            scope.emptyTemplate()

    calculate_access:->
        if ! @field_name || Lanes.Views.RenderContext.canWrite(@field_name)
            'write'
        else if Lanes.Views.RenderContext.canRead(@field_name)
            'read'
        else
            'none'


Lanes.Component.Base = Lanes.Views.Base.extend(BaseComponent)
