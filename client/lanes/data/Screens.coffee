class ScreenView extends Lanes.Data.BasicModel

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
        Lanes.Data.Screens.displaying.add( this )
        this.active=true

    renderScreen: ->
        this.view.render()

    remove: ->
        Lanes.Data.Screens.displaying.remove( this )



class ScreenDefinition extends Lanes.Data.BasicModel

    session:
        id:          'string'
        title:       'string'
        description: 'string'
        view:        'string'
        icon:        'string'
        group_id:    'string'
        files:       'array'
        loading:     'boolean'
        model:       'string'

    derived:
        model_type:
            deps: ['model'], fn: ->
                Lanes.getPath(this.model,"Lanes.Data")

    initialize: ->
        @views = []

    _setDisplaying: (viewport)->
        @views.push( new ScreenView( screen: this, viewport: viewport ) )

    getScreen: ->
        @viewModel ||= Lanes.getPath(this.view,"Lanes.Screens")
        if @viewModel?
            _.Promise.resolve(@viewMOdel)
        else
            this.loadScreen()

    loadScreen: ->
        me=this
        return new _.Promise(  (resolve,reject)->
             me.loading=true
             Lanes.lib.Request(me.files)
                 .then ->
                    me.loading=false
                    me.viewModel = Lanes.getPath(me.view)
                    if me.viewModel then resolve(me.viewModel)
                    else reject("Screen #{me.view} not definied after file retrieval")
                 ,(msg)->
                    Lanes.warn(msg)
                    me.loading=false
                    reject(msg)
        )


    display: (ui)->
        this.getScreen().then => @_setDisplaying(ui)

        # @viewModel ||= Lanes.Screens[this.view]
        # if @viewModel?
        #    this._setDisplaying(ui)
        # else
        #     this.loading=true
        #     Lanes.lib.Request(this.files)
        #         .then =>
        #             @viewModel = Lanes.Screens[this.view]
        #             @_setDisplaying(ui)
        #             @loading=false
        #         .catch (failures)=>
        #             @loading=false
        #             Lanes.warn(failures)


class ScreenViewSet extends Lanes.Data.BasicCollection

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



class ScreenSet extends Lanes.Data.BasicCollection

    model: ScreenDefinition

    register: (spec)->

    addScreen: (screen)->
        screen = this.add( screen )
        screen.set(active:true)



class MenuGroup extends Lanes.Data.BasicModel

    session:
        id:          'string'
        title:       'string'
        description: 'string'
        icon:        'string'
        active:      ['boolean', true, false]

    screens: ->
        @avail ||= new Lanes.Data.SubCollection( Lanes.Data.Screens.all, {
            filter: (screen)=>
                screen.group_id == @id && Lanes.current_user.canRead(screen.model_type)
            watched: ['group_id']
        })

class MenuGroupSet extends Lanes.Data.BasicCollection
    constructor: -> super
    model: MenuGroup

    available: ->
        @avail ||= new Lanes.Data.SubCollection(this, {
            filter: (mgs)=>
                mgs.screens().filter()
                mgs.screens().length > 0
        })



Lanes.Data.Screens = {
    all: new ScreenSet
    displaying: new ScreenViewSet([],{ single_active_only: true })
    groups:  new MenuGroupSet
    available_groups: ->
        MenuGroupSet.where({ id:  available.groupBy (screen)-> screen.group_id.keys })

    register: (spec)->
        this.all.add( spec )
}
