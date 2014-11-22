class TabView extends Lanes.Views.Base

    template: "<li><a data-toggle='tab'></a><span class='close'>×</span></li>"

    bindings:
        'model.screen.title': { selector: 'a', type: 'text' }
        'model.active': { type: 'booleanClass' }


    events:
        'click': 'onClick'

    onClick: (ev)->
        if ev.target.className == "close"
            this.model.remove()
        else
            this.model.active = true


TAB_PADDING = 0


class Lanes.Workspace.ActiveScreenSwitcher extends Lanes.Views.Base

    templateName: 'workspace/screens-switcher'

    key_scope: { name: 'nav', shortcut: '⌘+shift+t,ctrl+shift+t' }
    key_bindings:
        left:  'nextScreen'
        right: 'prevScreen'

    subviews:
        tab_views:
            container: '.nav-tabs'
            collection: 'collection'
            view: TabView

    events:
        'click .scroller-right': 'scrollRight'
        'click .scroller-left' : 'scrollLeft'

    nextScreen: -> this.collection.activateNext()
    prevScreen: -> this.collection.activatePrev()

    constructor: ->
        super
        _.bindAll(this, 'resetShownControls')
        @collection = Lanes.Data.Screens.displaying
        this.listenTo( @collection, "change:active", this.onActiveChange )
        this.listenTo( this.ui,  "change:viewport_width", this.resetShownControls )
        this.listenTo( Lanes.current_user, "change:isLoggedIn", this.closeScreens)


    closeScreens: ->
        @collection.remove(model) for model in this.collection.models

    widthOfList: ->
        itemsWidth = 0
        itemsWidth += tab.scrollWidth for tab in this.$("li")
        return itemsWidth

    onActiveChange: (screen,active)->
        return unless active
        if view = this.tab_views._getViewByModel(screen)
            this.scrollToTab( view.el )

    tabDisplayRange: ->
        start = this.tabs.position().left
        width = this.wrapper.width()
        end   = width + start
        { start: start, end: end, width: width, used: this.widthOfList() }

    scrollToTab: (li)->
        offset = li.offsetLeft
        width  = li.offsetWidth
        td = this.tabDisplayRange()
        diff = ( offset + td.start + width ) - td.width
        if diff > 0
            needs = if li.parentNode.lastElementChild == li then diff else width
            @tabs.animate( left: "-=" + needs + "px", @resetShownControls)
        else if offset + td.start < 0
            needs = if li.parentNode.firstElementChild == li then Math.abs(td.start) else width
            @tabs.animate( left: "+=" + needs + "px", @resetShownControls)

    resetShownControls: ->
        td = this.tabDisplayRange()
        if td.used < td.width
            this.lScroll.removeClass('enabled') ; this.rScroll.removeClass('enabled')
        else
            this.lScroll.toggleClass( 'enabled', td.start < 0)
            this.rScroll.toggleClass( 'enabled', !(td.used <= td.width-td.start) )

    scrollLeft: ->
        @rScroll.addClass('enabled')
        td = this.tabDisplayRange()
        scroll = _.min([Math.abs(td.start),td.width])
        @tabs.animate( left: "+=" + scroll + "px" )
        if td.start + scroll >= 0
            @lScroll.removeClass('enabled')

    scrollRight: ->
        @lScroll.addClass('enabled')
        td = this.tabDisplayRange()
        scroll = _.min([td.used - (td.width-td.start), td.width])
        @tabs.animate( left: "-=" + scroll + "px" )
        if Math.abs(td.start-scroll-td.width) >= td.used
            @rScroll.removeClass('enabled')

    render: ->
        super
        this.cacheJqElements({
            lScroll: '.scroller-left'
            rScroll: '.scroller-right'
            wrapper: '.wrapper'
            tabs:    '.nav-tabs'
        })
        this
