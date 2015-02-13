class Lanes.Workspace.Layout extends Lanes.Views.Base

    FILE: FILE
    templateName: 'layout'
    templateData: ->
        { ui: this.ui_state }
    mixins:[
        Lanes.Workspace.WorkspaceView
    ]
    subviews:
        navbar:
            hook: 'navbar-container'
            view: 'Navbar'
        pages:
            hook: 'page-container'
            view: 'Pages'

    session:
        ui_state: 'state'

    subviewOptions: ->
        { model: this.ui_state }

    constructor: (options={})->
        options.ui_state = new Lanes.Workspace.UIState( model: options.model, layout: this )
        super
