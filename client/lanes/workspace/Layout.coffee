class Lanes.Workspace.Layout extends Lanes.Views.Base

    templateName: 'layout'
    templateData: ->
        { ui: this.ui_state }
    mixins:[
        Lanes.Workspace.WorkspaceView
    ]
    subviews:
        navbar:
            hook: 'navbar-container'
            view: 'Lanes.Workspace.Navbar'
        pages:
            hook: 'page-container'
            view: 'Lanes.Workspace.Pages'

    session:
        ui_state: 'state'

    subviewOptions: ->
        { model: this.ui_state }

    constructor: (options={})->
        options.ui_state = new Lanes.Workspace.UIState( model: options.model, layout: this )
        super

    onRender: ->
        if Lanes.config.initial_workspace_screen_id
            Lanes.Screens.display_id(Lanes.config.initial_workspace_screen_id)
