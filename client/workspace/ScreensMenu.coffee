class ScreenList extends Lanes.Views.Base

    template: "<li><a href='#'><span></span><i></i></a></li>"

    events:
        click: 'displayScreen'

    displayScreen: ->
        this.model.display(this.ui)

    bindings:
        'model.title':{ selector: 'span', type: 'text' }
        'model.icon': { selector: 'i', type: 'class' }


class ScreenGroup extends Lanes.Views.Base

    template: -> '<li class="group"><a href="#"><span></span><i></i></a><ul></ul></li>'
    events:
        'click .group>a': 'toggleMenu'

    initialize: ->
        this.screens = @model.screens()

    subviews:
        navigation:
            container: 'ul'
            collection: 'screens'
            view: ScreenList

    bindings:
        'model.title':  { selector: '.group>a>span', type: 'text' }
        'model.icon':   { selector: '.group>a>i', type: 'class'   }
        'model.active': { selector: '', type: 'booleanClass', name:'active' }

    toggleMenu: (ev)->
        ev.preventDefault()
        @model.active = ! @model.active




class Lanes.Workspace.ScreensMenu extends Lanes.Views.Base

    constructor: -> super
    templateName: 'workspace/screens-menu'

    subviews:
        navigation:
            container: 'ul.navigation'
            collection: 'groups'
            view: ScreenGroup

    events:
        'highlight-hide': 'onHighlightHide'
        'highlight-show': 'onHighlightShown'
        'click .logout':  'onLogout'

    session:
        groups: 'collection'

    key_scope: { name: 'menu', shortcut: 'ctrl+shift+m' }
    key_bindings:
        up:    'prevMenu'
        down:  'nextMenu'
        enter: 'onEnter'
        right: 'expandMenu'
        left:  'collapseMenu'


    initialize: ->
        super
        this.listenTo(Lanes.current_user, "change:isLoggedIn", this.resetGroups)
        @groups = Lanes.Data.Screens.groups.available()
        this

    resetGroups: ->
        @groups.filter()

    onLogout: ->
        Lanes.current_user.logout()

    onHighlightShown: (ev)->
        this.getKeyboardFocus()

    onEnter: (ev)->
        focus = this.getKeyboardFocus()
        focus.trigger('click')
        if focus.hasClass("group")
            Lanes.Views.TimedHighlight.move( focus.find('ul li').first() )

    onHighlightHide: (ev)->
        Lanes.$(ev.target).closest('.navigation .expand').removeClass("expand")

    collapseMenu: ->
        current = this.getKeyboardFocus()
        focus = current.closest('.navigation .expand').removeClass("expand")
        return unless focus.length
        Lanes.Views.TimedHighlight.move( focus.first() )

    expandMenu: ->
        focus = this.getKeyboardFocus()
        return unless focus.find('ul li').length
        focus.addClass('expand')
        Lanes.Views.TimedHighlight.move( focus.find('ul li').first() )

    nextMenu: ->
        current = this.getKeyboardFocus()
        focus = current.next('li')
        focus = current.siblings('li:first') unless focus.length
        return unless focus.length
        Lanes.Views.TimedHighlight.move( focus.first() )

    prevMenu: ->
        current = this.getKeyboardFocus()
        focus = current.prev('li')
        focus = current.siblings('li:last') unless focus.length
        return unless focus.length
        Lanes.Views.TimedHighlight.move( focus.first() )

    getKeyboardFocus: ->
        focus = this.$('.highlighted')
        unless focus.length
            focus = this.$('.navigation li:first')
            Lanes.Views.TimedHighlight.move(focus)
        focus
