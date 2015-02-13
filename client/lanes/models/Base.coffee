# Da Model. Handles all things dataish
class BaseModel
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
        @changeMonitor = new Lanes.Models.ChangeMonitor(this)
        # The model was created with attributes and it did not originate from a XHR request
        if attrs and !options.xhr
            @changeMonitor.recordChanged(_.keys(attrs))

    # In some cases a model's security should depend on the parent record, not on itself.
    # For instance, a Customer's Address should have the same permissions as the Customer
    # This allows a subclass to specify the model type that should be checked.
    modelForAccess: -> this

    # used by PubSub to record a remote change to the model
    addChangeSet: (change)->
        this.changes ||= new Lanes.Models.ChangeSetCollection( parent: this )
        change.record = this
        change = this.changes.add(change)
        this.set( change.value() )

    urlRoot: ->
        Lanes.Models.Config.api_path + '/' + _.result(this,'api_path')

    # Default URL for the model's representation on the server
    url: ->
        base = _.result(this, 'urlRoot') || _.result(this.collection, 'url') || Lanes.Models.Sync.urlError();
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
    # The newly created record will not be stored in the PubSub map,
    # as only records bound to a view are stored there
    @findOrCreate: (attrs, options={})->
        if attrs.id && ( record = Lanes.Models.PubSub.instanceFor(this, attrs.id) )
            record.set(attrs)
        else
            new this(attrs,options)

    # Calls Ampersand State's set method, then sets any associations that are present as well
    set: (attrs,options)->
        super
        this.associations.set(this,attrs) if this.associations
        this

    # Loads records from the server that match query, returns a collection
    @where: (query, options)->
        this.Collection.fetch( _.extend({query: query}, options) )

    # Load a single record using an ID and the query options
    @fetchById: (id, options={})->
        record = new this(id: id)
        record.fetch(options)

    # Sets the attribute data from a server respose
    setFromServer: (data,options)->
        this.set( if _.isArray(data) then data[0] else data )
        this.changeMonitor.reset()

    # save the model's data to the server
    # Only unsaved attributes will be sent unless
    # the saveAll options is set to true
    save: (options={})->
        options = _.clone(options)

        options.saving=true
        handlers = Lanes.Models.Sync.wrapRequest(this,options)

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
        handlers = Lanes.Models.Sync.wrapRequest(this,options)
        _.extend(options,{limit:1,ignoreUnsaved:true})

        this.sync('read', this, options)
        handlers.promise

    # Removes the model's record from the server (if it is persistent)
    # and then fires the "destroy" event
    destroy: (options={})->
        handlers = Lanes.Models.Sync.wrapRequest(this,options)
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
    unsavedAttributes: ->
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
            data = this.unsavedAttributes()
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
    sync: Lanes.Models.Sync.perform

    # When the model is extended it auto-creates the created_at and updated_at
    # and sets up the AssociationMap
    @extended: (klass)->
        return if klass::abstractClass
        klass::props   ||= {}
        klass::session ||= {}

        klass::session['created_at'] ||= 'date'
        klass::session['updated_at'] ||= 'date'

        if klass::associations
            klass::associations = new Lanes.Models.AssocationMap(klass)

    @afterExtended: (klass)->
        if !klass::abstractClass && !klass.Collection
            class DefaultCollection
                constructor: -> super
                model: klass
            klass.Collection = Lanes.Models.Collection.extend(DefaultCollection)


Lanes.Models.Base = Lanes.lib.MakeBaseClass( Lanes.Vendor.Ampersand.State, BaseModel )



# ------------------------------------------------------------------ #
# The BasicModel is just a very thin layer over State                #
# ------------------------------------------------------------------ #
class BasicModel
    constructor: -> super
    isPersistent: -> false
    isModel: true

Lanes.Models.BasicModel = Lanes.lib.MakeBaseClass( Lanes.Vendor.Ampersand.State, BasicModel )


class State
    constructor: -> super

Lanes.Models.State = Lanes.lib.MakeBaseClass( Lanes.Vendor.Ampersand.State, State )
