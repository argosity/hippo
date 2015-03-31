class Lanes.Workspace.Navbar extends Lanes.Views.Base

    templateName: 'navbar'
    mixins:[
        Lanes.Workspace.WorkspaceView
    ]

    domEvents:
        'click .screens-menu-toggle': 'switchMenu'
        'click .navbar-toggle':  'showHideMenu'

    subviews:
        screens:
            hook: 'screens-container'
            view: 'Lanes.Workspace.ActiveScreenSwitcher'
            model: 'model'

    bindings:
        'menu_shown_class': { type: 'class' }
        'screen_menu_class': { type: 'class' }

    onActiveChange: ->
        this.$el.toggleClass('screens-menu-hidden',true)

    switchMenu: ->
        @model.nextSidebarState()

    showHideMenu: ->
        @model.toggle('screen_menu_shown')

    swallowMenu:(@menu)->
