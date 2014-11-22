class DataModel
    isModel: true

    constructor: (attrs,options)->
        this._unsaved = if attrs then _.keys(attrs) else []
        super
        this.on('change', this._recordUnsaved )

    session:
        errors: 'object'
        changes: { type: 'collection', setOnce: true }
        lastServerMessage: { type: 'string' }

    derived:
        error_message:
            deps:['errors'], fn: ->
                if !@errors then ''
                else if @errors.exception then @errors.exception
                else  _.toSentence( _.map(@errrors, (value,key)-> "#{key}: #{value}" ) )

    dataTypes:
        bigdec:
            set: (newVal)->
                val: new _.bigDecimal(newVal)
                type: 'bigdec'
            default: -> new _.bigDecimal(0)
        integer:
            set: (newVal)->
                val: parseInt(newVal)
                type: 'integer'
        date:
            get: (val)-> new Date(val)
            default: -> return new Date()
            set: (newVal)->
                if _.isDate(newVal)
                    newType='date'
                    newVal = newVal.valueOf();
                else
                    m=Lanes.Vendor.Moment(newVal)
                    if m.isValid()
                        newType='date'
                        newVal=m.toDate()
                    else
                        newType = typeof newVal;
                return {
                    val: newVal,
                    type: newType
                }

    modelForAccess: -> this

    isPersistent: ->
        !!( this.api_path && ! this.isNew() )

    addChangeSet: (change)->
        this.changes ||= new Lanes.Data.ChangeSetCollection( parent: this )
        change.record = this
        change = this.changes.add(change)
        this.set( change.value() )

    rootRecord: ->
        record = this.parent
        while record
            if record.parent then record = record.parent else break
        record

    urlRoot: ->
        Lanes.Data.Config.api_path + '/' + @resultsFor('api_path')

    setupStandardProps: -> Lanes.emptyFn

    isLoaded: ->
        !_.isEmpty( _.omit(this.attributes,this.idAttribute) )

    withAssociations: (names...,options={})->
        scope = options.scope || this
        if _.isString(options)
            names.push(options); options={}
        needed = _.filter( names, (name)->
            this._associations[name] && ! this._associations[name].instance(this).isLoaded()
        ,this)
        if _.isEmpty( needed )
            options.success.call(scope, this  ) if options.success
            options.complete.call(scope,this  ) if options.complete
            return _.Promise.resolve(this)
        else
            options['include']=needed
            this.fetch(options)
                .then (req)-> req.record

    @findOrCreate: (attrs, options={})->
        if attrs.id && ( record = Lanes.Data.PubSub.instanceFor(this, attrs.id) )
            record.set(attrs)
        else
            new this(attrs,options)

    @fetch: (options)->
        record = new this()
        if _.isNumber(options)
            record.id = options
            options = {}
        ret = record.fetch(options)
        ret

    fetch: (options={})->
        handlers = wrapRequest(this,options)
        super(_.extend(options,{limit:1,ignoreUnsaved:true})).then( =>@ )
        handlers.promise

    parse:(resp)->
        if resp.data
            if _.isArray(resp['data']) then resp['data'][0] else resp['data']
        else
            resp

    set: (attrs,options)->
        super
        if _.isObject(attrs) && ! options?.saving
            for name, association of this._associations||{}
                association.instance(this).set(attrs[association.name], options) if attrs[association.name]
        this

    save: (options={})->
        options.setFromResponse=true
        options.saving=true
        handlers = wrapRequest(this,options)
        super({}, options)
        handlers.promise

    dataForSave: (options={})->
        if options.saveAll
            data = @attributes
        else
            data = this.unsavedData()
        for name, association of this._associations||{}
            if association.isCreated(this) && association.instance(this).isDirty()
                instance = association.instance(this)
                data[association.name] = if options.saveAll then instance.attributes else instance.unsavedData()
        data

    destroy: (options={})->
        handlers = wrapRequest(this,options)
        super(options)
        handlers.promise

    unsavedData: ->
        attrs = if this.isNew() then {} else { id: this.getId() }
        _.extend(attrs, _.pick( this.attributes, @_unsaved... ) )

    isDirty:->
          !!@_unsaved.length

    hasAttribute: (name)->
        !!this._definition[name]

    associationDefinition: (name,options)->
        _.extend(options, {
            fk: options.fk || name + "_id"
            name: name
            isCreated: (parent)->
                parent._cache.hasOwnProperty(@name)
            instance:  (parent)-> parent[@name]
        })


    associationDerivedDefinition: (name,definition)->
        klass = associationLookupClass(definition)
        {
            deps: [definition.fk]
            fn: ->
                args = {}
                args['id'] = this.get(definition.fk) if this.get(definition.fk)
                if definition.defaultValue
                    _.defaults(args, _.evaluateFunction(definition.defaultValue))
                klass ||= associationLookupClass(definition)
                record = klass.findOrCreate(args)
                record.parent = this
                record
        }

    validateFieldChange: (name, value)->
        return '' unless def = this._definition[name]
        if def.required && _.isEmpty(value)
            "Cannot be empty"
        else
            ''

    sync: ->
        Lanes.Data.Sync.apply(this,arguments)

    _recordUnsaved: (record,options)->
        attrs = this.changedAttributes()
        unless options?.silent || options?.ignoreUnsaved
            for name,val of attrs
                @_unsaved.push( name ) if -1 == @_unsaved.indexOf(name)
        this


    @extended: (klass)->
        klass.prototype.props        ||= {}
        klass.prototype.session      ||= {}
        klass.prototype.associations ||= {}
        (klass.prototype.addStandardProperties || setupStandardProps).call(klass, klass.prototype)

        setupAssociations(klass.prototype) if klass.prototype.associations


    Lanes.lib.ModuleSupport.includeInto(@)
    @include Lanes.lib.results


associationLookupClass = (definition)->
    object = definition.model || definition.collection
    if _.isObject(object) then object else Lanes.getPath( object, "Lanes.Data")

setupAssociations=(klass)->
    klass.derived     ||= {}
    klass._associations = {}
    derivedFn = ( klass.associationDerivedDefinition || DataModel.prototype.associationDerivedDefinition )
    createFn  = ( klass.associationDefinition        || DataModel.prototype.associationDefinition)
    for name, options of klass.associations
        definition = createFn.call(klass, name, options)
        klass.derived[ name ] = derivedFn.call(klass, name, definition)
        klass._associations[name] = definition

setupStandardProps=(klass)->
    klass.session['created_at'] ||= 'date'
    klass.session['updated_at'] ||= 'date'
    klass.associations['created_by'] ||= { model: 'Lanes.Data.User' }
    klass.associations['updated_by'] ||= { model: 'Lanes.Data.User' }

copyServerResp = (record,resp)->
    record.errors = resp?.errors
    record.lastServerMessage = resp.message
    { record: record, response: resp }

wrapRequest = (record, options)->
    error   = options.error
    success = options.success
    options.promise = new _.Promise( (resolve,reject)->
        options.resolvePromise = resolve
        options.rejectPromise  = reject
    )
    options.error = (record, resp, req)->
        options.rejectPromise( copyServerResp(record,resp.responseJSON || {error: resp.responseText}) )
        error?.apply(options.scope, arguments)

    options.success = (record,resp,req)->
        options.resolvePromise( copyServerResp(record,resp) )
        record._unsaved = []
        success?.apply(options.scope, arguments)
    options


Lanes.Data.Model = Lanes.lib.MakeBaseClass( Lanes.Vendor.Ampersand.Model, DataModel )


class BasicModel
    constructor: -> super
    isPersistent: -> false
    isModel: true

Lanes.Data.BasicModel = Lanes.lib.MakeBaseClass( Lanes.Vendor.Ampersand.Model, BasicModel )


class State
    constructor: -> super

Lanes.Data.State = Lanes.lib.MakeBaseClass( Lanes.Vendor.Ampersand.State, State )
