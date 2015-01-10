class Lanes.Workspace.Layout extends Lanes.Views.Base

    templateName: 'layout'
    mixins:[
        Lanes.Workspace.WorkspaceView
    ]
    FILE: FILE

    subviews:
        navbar:
            hook: 'navbar-container'
            view: 'Workspace.Navbar'

        pages:
            hook: 'page-container'
            view: 'Workspace.Pages'

    subviewOptions: -> { model: this.model }

    onRender: ->
        @screens = new Lanes.Workspace.ScreensMenu({ parent: this, model: @model })
        this.viewport.menu_view = @screens.render()
