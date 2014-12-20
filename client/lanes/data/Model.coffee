
# ------------------------------------------------------------------ #
# The ModelChangeMonitor watches for changes on the                  #
# Model and remembers which attributes have been changed             #
# ------------------------------------------------------------------ #
class ModelChangeMonitor
    constructor: (@model)->
        @model.on('change', this.onChange, this)

    onChange: (record,options)->
        attrs = @model.changedAttributes()
        this.recordChanged( _.keys(attrs) )

    recordChanged: (names)->
        @_unsaved ||= {}
        for name in names
            this.recordChangedAttribute(name)

    changedAttributes: ->
        _.keys(@_unsaved)

    recordChangedAttribute:(name)->
        if @model._definition[name] && !@model._definition[name].session
            @_unsaved[ name ] = true

    reset: ->
        delete @_unsaved

    isDirty: ->
        !_.isEmpty(@_unsaved)

# ------------------------------------------------------------------ #
# Handles Association definitions.                                   #
# It creates a derived definition for each one                       #
# and contains utility functions to operate on them                  #
# ------------------------------------------------------------------ #
class AssocationMap
    constructor: (@klass)->
        @klass::derived ||= {}
        @definitions = @klass::associations
        @definitions['created_by'] ||= { model: 'Lanes.Data.User', readOnly: true }
        @definitions['updated_by'] ||= { model: 'Lanes.Data.User', readOnly: true }
        for name, options of @definitions
            @klass::derived[name] = this.derivedDefinition(name,options)

    # returns the definition for the derived property
    derivedDefinition: (name,definition)->
        findAssocationClass = ->
            object = definition.model || definition.collection
            if _.isObject(object) then object else Lanes.getPath( object, "Lanes.Data")
        target_klass = findAssocationClass()
        # will be called in the scope of the model
        createAssocation = ->
            args = {}
            args['id'] = this.get(definition.fk) if this.get(definition.fk)
            if definition.defaultValue
                _.defaults(args, _.evaluateFunction(definition.defaultValue))
            target_klass ||= findAssociationClass() # it might not have been present previously
            record = target_klass.findOrCreate(args)
            record.parent = this
            record        
        { deps: [definition.fk], fn: createAssocation }

    # Sets the assocations for "model"
    set: (model, data)->
        for name, value of data
            model[name].set(value) if _.has(@definitions, name)

    # returns the data from all assocations for saving
    dataForSave: (model,options)->
        ret = {}
        for name, options of @definitions
            unless options.readOnly
                ret[name] = model[name].dataForSave(options)
        ret

    # return a list of assocations from "name" that are not loaded
    nonLoaded: (model, names)->
        list = []
        for name in names
            if _.has(@definitions, name) && !model[name].isLoaded()
                list.push(name)
        list


# Da Model. Handles all things dataish
class DataModel
    isModel: true
    session:
        errors: 'object'
        changes: { type: 'collection', setOnce: true }
        lastServerMessage: { type: 'string' }
    derived:
        errorMessage:
            deps:['errors'], fn: ->
                if !@errors then ''
                else if @errors.exception then @errors.exception
                else  _.toSentence( _.map(@errrors, (value,key)-> "#{key}: #{value}" ) )
    dataTypes:
        # Big decimal for attributes that need precision math
        bigdec:
            set: (newVal)->
                val: new _.bigDecimal(newVal)
                type: 'bigdec'
            default: -> new _.bigDecimal(0)
        integer:
            set: (newVal)->
                val: parseInt(newVal)
                type: 'integer'
        # Uses the "moment" lib to parse dates and coerce strings into the date type.
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

    constructor: (attrs,options={})->
        super
        @changeMonitor = new ModelChangeMonitor(this)
        # The model was created with attributes and it did not originate from a XHR request
        if attrs and !options.xhr
            @changeMonitor.recordChanged(_.keys(attrs))

    # In some cases a model's security should depend on the parent record, not on itself.
    # For instance, a Customer's Address should have the same permissions as the Customer
    # This allows a subclass to specify the model type that should be checked.
    modelForAccess: -> this

    # used by PubSub to record a remote change to the model
    addChangeSet: (change)->
        this.changes ||= new Lanes.Data.ChangeSetCollection( parent: this )
        change.record = this
        change = this.changes.add(change)
        this.set( change.value() )

    urlRoot: ->
        Lanes.Data.Config.api_path + '/' + _.result(this,'api_path')

    # Default URL for the model's representation on the server
    url: ->
        base = _.result(this, 'urlRoot') || _.result(this.collection, 'url') || Lanes.Data.Sync.urlError();
        if this.isNew() then return base;
        if base.charAt(base.length - 1) != '/'
             base += "/"
        return base + encodeURIComponent(this.getId())

    
    # A record is considered loaded if it has the id set and some attributes set
    isLoaded: ->
        !this.isNew() && !_.isEmpty( _.omit(this.attributes,this.idAttribute) )

    # is the record saved
    isPersistent: ->
        !!( this.api_path && ! this.isNew() )

    # Ensures the assocations given in "needed" are loaded
    withAssociations: (names...,options={})->
        scope = options.scope || this
        if _.isString(options)
            names.push(options); options={}
        needed = this.associations.nonLoaded(this,names)
        if _.isEmpty( needed )
            options.success.call(scope, this  ) if options.success
            options.complete.call(scope,this  ) if options.complete
            return _.Promise.resolve(this)
        else
            options['include']=needed
            this.fetch(options)
                .then (req)-> req.record

    # Searches the PubSub idenity map for a record of the same type and matching id
    # If one is found, it will update it with the given attributes and return it
    # When not found, it will create a new record and return it.
    # The newly created record will not be stored, in PubSub map, only records bound to a view are stored
    @findOrCreate: (attrs, options={})->
        if attrs.id && ( record = Lanes.Data.PubSub.instanceFor(this, attrs.id) )
            record.set(attrs)
        else
            new this(attrs,options)

    # Fetch a single record using an ID and the query options
    @fetch: (id, options={})->
        record = new this()
        if _.isNumber(id)
            record.id = id
        record.fetch(options)

    # Calls Ampersand State's set method, then sets any associations that are present as well
    set: (attrs,options)->
        super
        this.associations.set(this,attrs) if this.associations
        this

    where: (query,options)->
        collection = new @CollectionType
        collection.fetch( _.extend({query: query}, options) )
        collection

    # Sets the attribute data from a server respose
    setFromResponse: (data,options)->
        this.set( if _.isArray(data) then data[0] else data )
        this.changeMonitor.reset()

    # save the model's data to the server
    # Only unsaved attributes will be sent unless
    # the saveAll options is set to true
    save: (options={})->
        options = _.clone(options)

        options.saving=true
        handlers = Lanes.Data.Sync.wrapRequest(this,options)

        method = if this.isNew()
            'create'
        else
            if options.saveAll then 'update' else 'patch'
        
        sync = this.sync(method, this, options);

        handlers.promise

    # Fetch the model from the server. If the server's representation of the
    # model differs from its current attributes, they will be overridden,
    # triggering a `"change"` event.
    fetch:  (options={}) ->
        options = _.clone(options)
        handlers = Lanes.Data.Sync.wrapRequest(this,options)
        _.extend(options,{limit:1,ignoreUnsaved:true})

        this.sync('read', this, options)
        handlers.promise

    # Removes the model's record from the server (if it is persistent)
    # and then fires the "destroy" event
    destroy: (options={})->
        handlers = Lanes.Data.Sync.wrapRequest(this,options)
        model    = this
        success  = options.success
        options.success = (reply, msg, options)->
            model.trigger('destroy', model, model.collection, options)
            if success then success(model, reply, options)

        if this.isNew()
            options.success()
            return false
        this.sync('delete', this, options)
        handlers.promise

    # returns any attributes that have been set and not saved
    unsavedData: ->
        attrs = if this.isNew() then {} else { id: this.getId() }
        _.extend(attrs, _.pick( this.getAttributes(props:true, true),
            @changeMonitor.changedAttributes() ) )

    # returns data to save to server.  If options.saveAll is true,
    # all data is returned.  Otherwise only unsaved attributes (and associations)
    # are returned.
    dataForSave: (options={})->
        if options.saveAll
            data = this.getAttributes(props:true, true)
        else
            data = this.unsavedData()
        _.extend(data, this.associations.dataForSave(this, options)) if this.associations
        data


    # returns true if any server-side attributes are unsaved
    # Does not care about session-only properties
    isDirty: ->
        @changeMonitor.isDirty()

    # True if the model has "name" as eitehr a prop or session attribute
    hasAttribute: (name)->
        !!this._definition[name]

    # Check if an attribute named "name" can be set to "value"
    # Returns an empty string if value, and an appropriate error message if not
    checkValid: (name, value)->
        return '' unless def = this._definition[name]
        if def.required && _.isEmpty(value)
            "Cannot be empty"
        else
            ''
    # Use Sync directly
    sync: Lanes.Data.Sync.perform

    # When the model is extended it auto-creates the created_at and updated_at
    # and sets up the AssociationMap
    @extended: (klass)->
        klass::props   ||= {}
        klass::session ||= {}

        klass::session['created_at'] ||= 'date'
        klass::session['updated_at'] ||= 'date'

        if klass::associations
            klass::associations = new AssocationMap(klass) 

        unless klass::CollectionType
            class DefaultCollection
                constructor: -> super
                model: klass
            klass::CollectionType = Lanes.Data.Collection.extend(DefaultCollection)

Lanes.Data.Model = Lanes.lib.MakeBaseClass( Lanes.Vendor.Ampersand.State, DataModel )



# ------------------------------------------------------------------ #
# The BasicModel is just a very thin layer over State                #
# ------------------------------------------------------------------ #
class BasicModel                #
    constructor: -> super
    isPersistent: -> false
    isModel: true

Lanes.Data.BasicModel = Lanes.lib.MakeBaseClass( Lanes.Vendor.Ampersand.State, BasicModel )


class State
    constructor: -> super

Lanes.Data.State = Lanes.lib.MakeBaseClass( Lanes.Vendor.Ampersand.State, State )
