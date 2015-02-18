class TabView extends Lanes.Views.Base

    template: "<li><a data-toggle='tab'></a><span class='close'>×</span></li>"
    FILE: FILE
    mixins:[
        Lanes.Workspace.WorkspaceView
    ]
    bindings:
        'model.screen.title': { selector: 'a', type: 'text' }
        'model.active': { type: 'booleanClass' }
    domEvents:
        'click': 'onClick'

    onClick: (ev)->
        if ev.target.className == "close"
            this.model.remove()
        else
            this.model.active = true


TAB_PADDING = 0


class Lanes.Workspace.ActiveScreenSwitcher extends Lanes.Views.Base

    templateName: 'screens-switcher'
    mixins:[
        Lanes.Workspace.WorkspaceView
    ]
    keyScope: { name: 'nav', shortcut: '⌘+shift+t,ctrl+shift+t' }
    keyBindings:
        left:  'nextScreen'
        right: 'prevScreen'
    subviews:
        tab_views:
            container: '.nav-tabs'
            collection: 'collection'
            view: TabView
    ui:
        lScroll: '.scroller-left'
        rScroll: '.scroller-right'
        wrapper: '.wrapper'
        tabs:    '.nav-tabs'

    domEvents:
        'click .scroller-right': 'scrollRight'
        'click .scroller-left' : 'scrollLeft'

    nextScreen: -> this.collection.activateNext()
    prevScreen: -> this.collection.activatePrev()

    constructor: ->
        super
        _.bindAll(this, 'resetShownControls')
        @collection = Lanes.Screens.Definitions.displaying
        this.listenTo( @collection,        "change:active",     this.onActiveChange)
        this.listenTo( this.viewport,      "change:width",      this.resetShownControls)
        this.listenTo( Lanes.current_user, "change:isLoggedIn", this.closeScreens)

    closeScreens: ->
        @collection.reset()

    widthOfList: ->
        itemsWidth = 0
        itemsWidth += tab.scrollWidth for tab in this.$("li")
        return itemsWidth

    onActiveChange: (screen,active)->
        return unless active
        if view = this.tab_views._getViewByModel(screen)
            this.scrollToTab( view.el )

    tabDisplayRange: ->
        start = this.ui.tabs.position().left
        width = this.ui.wrapper.width()
        end   = width + start
        { start: start, end: end, width: width, used: this.widthOfList() }

    scrollToTab: (li)->
        offset = li.offsetLeft
        width  = li.offsetWidth
        td = this.tabDisplayRange()
        diff = ( offset + td.start + width ) - td.width
        if diff > 0
            needs = if li.parentNode.lastElementChild == li then diff else width
            this.ui.tabs.animate( left: "-=" + needs + "px", @resetShownControls)
        else if offset + td.start < 0
            needs = if li.parentNode.firstElementChild == li then Math.abs(td.start) else width
            this.ui.tabs.animate( left: "+=" + needs + "px", @resetShownControls)

    resetShownControls: ->
        td = this.tabDisplayRange()
        if td.used < td.width
            this.ui.lScroll.removeClass('enabled') ; this.ui.rScroll.removeClass('enabled')
        else
            this.ui.lScroll.toggleClass( 'enabled', td.start < 0)
            this.ui.rScroll.toggleClass( 'enabled', !(td.used <= td.width-td.start) )

    scrollLeft: ->
        this.ui.rScroll.addClass('enabled')
        td = this.tabDisplayRange()
        scroll = _.min([Math.abs(td.start),td.width])
        this.ui.tabs.animate( left: "+=" + scroll + "px" )
        if td.start + scroll >= 0
            this.ui.lScroll.removeClass('enabled')

    scrollRight: ->
        this.ui.lScroll.addClass('enabled')
        td = this.tabDisplayRange()
        scroll = _.min([td.used - (td.width-td.start), td.width])
        this.ui.tabs.animate( left: "-=" + scroll + "px" )
        if Math.abs(td.start-scroll-td.width) >= td.used
            this.ui.rScroll.removeClass('enabled')
