class Lanes.Workspace.Navbar extends Lanes.Views.Base

    templateName: 'navbar'
    FILE: FILE
    mixins:[
        Lanes.Workspace.WorkspaceView
    ]

    events:
        'click .screens-menu-toggle': 'switchMenu'
        'click .navbar-toggle':  'showHideMenu'

    subviews:
        screens:
            hook: 'screens-container'
            view: 'Workspace.ActiveScreenSwitcher'
            model: 'model'

    bindings:
        'menu_shown_class': { type: 'class' }
        'screen_menu_class': { type: 'class' }

    derived:
        menu_shown_class:
            deps: ['model.screen_menu_shown']
            fn: -> if @model.screen_menu_shown then 'screen-menu-visible' else 'screen-menu-hidden'
        screen_menu_class:
            deps: ['model.screen_menu_position']
            fn: -> if @model.screen_menu_position == 'top' then 'with-screen-menu' else 'no-screen-menu'


    initialize: ->
        this.listenTo(@model,'change:screen_menu_position', this.moveScreensMenu )

    onActiveChange: ->
        this.$el.toggleClass('screens-menu-hidden',true)

    moveScreensMenu: ->
        if 'top' == @model.screen_menu_position
            this.query('.menu-container').appendChild( @model.menu_view.el )

    switchMenu: ->
        @model.nextSidebarState()

    showHideMenu: ->
        @model.toggle('screen_menu_shown')

    swallowMenu:(@menu)->
