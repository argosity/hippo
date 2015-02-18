class Lanes.Workspace.Pages extends Lanes.Views.Base

    templateName: 'pages'
    FILE: FILE
    mixins:[
        Lanes.Workspace.WorkspaceView
    ]

    bindings:
        'model.layout_size': { selector: '.page-content', type: 'class' }
        'model.screen_menu_size': { type: 'class' }
        'model.popover_menu': { type: 'booleanClass', name: 'popover-menu' }

    subviews:
        menu:
            view: 'ScreensMenu'

    ui:
        screen: '.screen'

    initialize: (options)->
        this.listenTo( Lanes.current_user,                   "change:isLoggedIn", this.closeScreens)
        this.listenTo( Lanes.Screens.Definitions.displaying, "change:active",     this.onActiveChange)
        super

    closeScreens: ->
        this.ui.screen.children().detach()

    onRemove: (screen)->
        screen.view.remove()

    onActiveChange: (screen,active)->
        view = screen.view
        view.parent = this
        unless view.rendered
            view.render()
        if active
            this.ui.screen.append( view.el )
        else
            view.$el.detach()
