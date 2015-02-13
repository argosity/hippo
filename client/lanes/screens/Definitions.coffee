class ScreenView extends Lanes.Models.BasicModel
    FILE: FILE

    session:
        screen: 'object'

    session:
        active: ['boolean', true, false]
        viewport: 'state'

    derived:
        view:
            deps: ['screen'], fn: ->
                if @screen?.viewModel?
                    new @screen.viewModel( screen: this.screen, viewport: this.viewport )
                else
                    Lanes.warn("Undefined screen for #{this}")

    initialize: (options)->
        super
        @screen=options.screen
        Lanes.Screens.Definitions.displaying.add( this )
        this.active=true

    renderScreen: ->
        this.view.render()

    remove: ->
        Lanes.Screens.Definitions.displaying.remove( this )



class ScreenDefinition extends Lanes.Models.BasicModel
    FILE: FILE

    session:
        id:          'string'
        title:       'string'
        description: 'string'
        view:        'string'
        icon:        'string'
        group_id:    'string'
        loading:     'boolean'
        model:       'string'
        assets:      'array'
        js:          'string'
        css:         'string'

    derived:
        model_type:
            deps: ['model'], fn: ->
                Lanes.u.findObject(@model, "Models", this.FILE)

    initialize: ->
        @views = []

    _setDisplaying: (viewport)->
        @views.push( new ScreenView( screen: this, viewport: viewport ) )

    getScreen: ->
        @viewModel ||= Lanes.u.getPath(this.view,@FILE?['Views'])
        if @viewModel?
            _.Promise.resolve(@viewMOdel)
        else
            this.loadScreen()

    loadScreen: ->
        me=this
        return new _.Promise( (resolve,reject)->
             me.loading=true
             Lanes.lib.Request(me.assets)
                 .then ->
                    me.loading=false
                    me.viewModel = Lanes.u.getPath(me.view, me.FILE?['Views'])
                    if me.viewModel then resolve(me.viewModel)
                    else reject("Screen #{me.view} not definied after file retrieval")
                 ,(msg)->
                    Lanes.warn(msg)
                    me.loading=false
                    reject(msg)
        )


    display: (ui)->
        this.getScreen().then => @_setDisplaying(ui)


class ScreenViewSet extends Lanes.Models.BasicCollection
    FILE: FILE

    model: ScreenView

    active: ->
        @findWhere( active: true )

    initialize: (models, options={})->
        this.on( 'change:active', this.onActiveChange )

    remove: (model)->
        index = this.indexOf(model)
        super
        if model.active && this.length
            this.at(_.min([index,this.length-1])).active = true
        model.active = false
        this

    onActiveChange: (changed,active)->
        return unless active
        this.each (screen)->
            screen.set( active: false ) unless screen == changed

    activateNext: -> this._moveActive(+1)
    activatePrev: -> this._moveActive(-1)

    _moveActive: (inc)->
        return if this.length == 1
        current = this.findIndexWhere( active: true )
        return if current == -1
        if inc>0 && current == this.length-1
            current = -1
        if inc<0 && current == 0
            current = this.length
        this.at(current+inc).active = true



class ScreenSet extends Lanes.Models.BasicCollection
    FILE: FILE

    model: ScreenDefinition

    register: (spec)->

    addScreen: (screen)->
        screen = this.add( screen )
        screen.set(active:true)



class MenuGroup extends Lanes.Models.BasicModel
    FILE: FILE

    session:
        id:          'string'
        title:       'string'
        description: 'string'
        icon:        'string'
        active:      ['boolean', true, false]

    screens: ->
        @avail ||= new Lanes.Models.SubCollection( Lanes.Screens.Definitions.all, {
            filter: (screen)=>
                screen.group_id == @id &&
                    (!screen.model_type || Lanes.current_user.canRead(screen.model_type))
            watched: ['group_id']
        })

class MenuGroupSet extends Lanes.Models.BasicCollection
    FILE: FILE

    constructor: -> super
    model: MenuGroup

    available: ->
        @avail ||= new Lanes.Models.SubCollection(this, {
            filter: (mgs)=>
                mgs.screens().filter()
                mgs.screens().length > 0
        })

Lanes.Screens.display_id = (screen_id)->
    definition = Lanes.Screens.Definitions.all.get(screen_id)
    if (definition)
        definition.display()
    else
        Lanes.warn "Unable to find definition for screen #{screen_id}"

Lanes.Screens.Definitions = {
    all: new ScreenSet
    displaying: new ScreenViewSet([],{ single_active_only: true })
    groups:  new MenuGroupSet
    available_groups: ->
        MenuGroupSet.where({ id:  available.groupBy (screen)-> screen.group_id.keys })

    register: (spec)->
        this.all.add( spec )
}
