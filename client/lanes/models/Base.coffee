# These prototype properties are also
# set on any Collections that are created
PROPERTIES_SHARED_WITH_DEFAULT_COLLECTION = [
    'cacheDuration'
]

# Da Model. Handles all things dataish
class BaseModel
    isModel: true
    session:
        errors: 'object'
        changes: { type: 'collection', setOnce: true }
        lastServerMessage: { type: 'string' }
        parent: 'state'
        isDirty: { type: 'boolean', default: false }

    derived:
        errorMessage:
            deps:['errors'], fn: ->
                if !@errors then ''
                else if @errors.exception then @errors.exception
                else  _.toSentence( _.map(@errors, (value, key) ->
                    _.titleize(_.humanize(key)) + ' ' + value
                ))
    dataTypes:
        code:
            set: (newVal) ->
                if _.isString(newVal)
                    val: newVal.toUpperCase(), type: 'code'
                else
                    throw new TypeError('code must be a string')
            default: -> ''
        # Big decimal for attributes that need precision math
        bigdec:
            set: (newVal) ->
                val = _.bigDecimal(newVal) unless _.isBlank(newVal)
                { val, type: 'bigdec' }
            default: -> new _.bigDecimal(0)

        integer:
            set: (newVal) ->
                val = parseInt(newVal, 10) unless _.isBlank(newVal)
                {val, type: 'integer'}
        # Uses the "moment" lib to parse dates and coerce strings into the date type.
        date:
            get: (val) -> new Date(val)
            default: -> return new Date()
            set: (newVal) ->
                if _.isDate(newVal)
                    newType = 'date'
                    newVal = newVal.valueOf()
                else
                    m = Lanes.Vendor.Moment(newVal)
                    if m.isValid()
                        newType = 'date'
                        newVal = m.toDate()
                    else
                        newType = typeof newVal;
                return {
                    val: newVal,
                    type: newType
                }

    constructor: (attrs, options = {}) ->
        super
        @changeMonitor = new Lanes.Models.ChangeMonitor(this)
        # The model was created with attributes and it did not originate from a XHR request
        if attrs and !options.xhr
            @changeMonitor.recordChanges(this, _.keys(attrs))

    # In some cases a model's security should depend on the parent record, not on itself.
    # For instance, a Customer's Address should have the same permissions as the Customer
    # This allows a subclass to specify the model type that should be checked.
    modelForAccess: -> this

    # is the record saved
    isPersistent: ->
        !!( _.result(this, 'api_path') && !this.isNew() )

    # used by PubSub to record a remote change to the model
    addChangeSet: (change) ->
        change = new Lanes.Models.ChangeSet(change)
        this.set( change.value(), silent: true )
        for name, value of change.value()
            this.trigger("remote-update:#{name}", "changeset", this, change)
        this.triggerChangeSet(this, change)

    triggerChangeSet: (triggered, change) ->
        this.changes ||= new Lanes.Models.ChangeSet.Collection( parent: this )
        this.changes.add(change)
        this.trigger('remote-update', triggered, change)
        @parent?.triggerChangeSet?(triggered, change)

    api_path: ->
        path = if this.FILE then _.last(this.FILE.path) else ''
        _.pluralize(_.dasherize(path))

    urlRoot: ->
        Lanes.config.api_path + '/' + _.result(this, 'api_path')

    # Default URL for the model's representation on the server
    url: ->
        base = _.result(this, 'urlRoot') || _.result(this.collection, 'url') || Lanes.Models.Sync.urlError()
        if this.isNew() then return base
        if base.charAt(base.length - 1) != '/'
            base += "/"
        return base + encodeURIComponent(this.getId())


    # Ensures the assocations given in "names" are loaded
    withAssociations: (names, options = {}) ->
        needed = this.associations?.nonLoaded(this, names)
        if _.isEmpty( needed ) and not options.force
            return _.Promise.resolve(this)
        else
            options['include'] = needed
            this.fetch(options)

    # replace this model's attributes with data from other model
    copyFrom: (model) ->
        attributes = if _.isFunction(model.serialize) then model.serialize() else model
        _.extend(attributes, model.getAttributes(session: true) ) if Lanes.u.isState(model)
        this.set(attributes)

    # duplicate the model.  Copies only attributes, not bound events
    clone: ->
        new @constructor(@attributes)

    serialize: ->
        _.extend(super,
            this.associations?.serialize(this)
        )

    # Calls Ampersand State's set method, then sets any associations that are present as well
    set: (key, value, options) ->
        # Handle both `"key", value` and `{key: value}` -style arguments.
        if _.isObject(key) || key == null
            attrs = key
            options = value
        else
            attrs = {}
            attrs[key] = value
        super
        this.associations.set(this, attrs, options) if this.associations
        this

    # Loads records from the server that match query, returns a collection
    @where: (query, options) ->
        this.Collection.fetch( _.extend({query: query}, options) )

    # Load a single record using an ID and the query options
    @fetchById: (id, options = {}) ->
        record = new this(id: id)
        record.fetch(options)
        record

    # Sets the attribute data from a server respose
    setFromServer: (data, options) ->
        data = if _.isArray(data) then data[0] else data
        BaseModel.__super__.set.call(this, data )
        this.associations.setFromServer(this, data, options) if this.associations
        this.isDirty = false

    # save the model's data to the server
    # Only unsaved attributes will be sent unless
    # the saveAll options is set to true
    save: (options = {}) ->
        options = _.clone(options)
        options.saving = true

        method = if this.isNew()
            'create'
        else
            if options.saveAll then 'update' else 'patch'

        this.sync(method, this, options)


    # Fetch the model from the server. If the server's representation of the
    # model differs from its current attributes, they will be overridden,
    # triggering a `"change"` event.
    fetch:  (original_options = {}) ->
        options = _.clone(original_options)
        options = _.extend(options, {limit:1, ignoreUnsaved:true})

        if this.cacheDuration && _.isEmpty(original_options)
            Lanes.Models.ServerCache.fetchRecord(this, options)
        else
            this.sync('read', this, options)


    @fetch: (options = {}) ->
        record = new this()
        record.fetch(options)

    # Removes the model's record from the server (if it is persistent)
    # and then fires the "destroy" event
    destroy: (options = {}) ->
        if this.isNew()
            _.Promise.resolve(this)
        this.sync('delete', this, options).then (model) ->
            model.trigger('destroy', model, model.collection, options)
            model

    # returns any attributes that have been set and not saved
    unsavedAttributes: ->
        attrs = {}
        _.extend(attrs, _.pick( this.getAttributes(props:true, true),
            @changeMonitor.changedAttributes() ) )
        attrs

    # returns data to save to server.  If options.saveAll is true,
    # all data is returned.  Otherwise only unsaved attributes (and associations)
    # are returned.
    dataForSave: (options = {}) ->
        if options.saveAll || this.isNew()
            data = this.getAttributes(props:true, true)
        else
            data = this.unsavedAttributes()
        if this.associations && (!_.isEmpty(data) || !this.isNew())
            data.id = this.getId() unless this.isNew()
            _.extend(data, this.associations.dataForSave(this, options))
        data


    # True if the model has "name" as either a prop or session attribute
    hasAttribute: (name) ->
        !! (this._definition[name] || this._derived[name])

    # Uses Lanes.Models.Sync by default
    sync: (options...) ->
        Lanes.Models.Sync.state(options...)

    # When the model is extended it auto-creates the created_at and updated_at
    # and sets up the AssociationMap
    @extended: (klass) ->
        return if klass::abstractClass
        klass::props   ||= {}
        klass::session ||= {}

        klass::session['created_at'] ||= 'date'
        klass::session['updated_at'] ||= 'date'

        if klass::associations
            klass::associations = new Lanes.Models.AssocationMap(klass)

    @afterExtended: (klass) ->
        return if klass::abstractClass
        unless klass.Collection
            @createDefaultCollectionFor(klass)

        if klass::enums
            klass::enums = new Lanes.Models.EnumMap(klass)


    @createDefaultCollectionFor: (klass) ->
        name = "#{klass.name}Collection"
        Collection = new Function("return function #{name}(){
            #{name}.__super__.constructor.apply(this, arguments);
        }")()
        Collection::model = klass
        for prop in PROPERTIES_SHARED_WITH_DEFAULT_COLLECTION
            Collection::[prop] = klass::[prop] if klass::[prop]
        klass.Collection = Lanes.Models.Collection.extend(Collection)

    Lanes.lib.ModuleSupport.includeInto(@)
    @include Lanes.lib.results


class State
    constructor: -> super
    isState: true

    # ## listenToAndRun
    # Shortcut for registering a listener for a model
    # and also triggering it right away.
    listenToAndRun: (object, events, handler) ->
        bound = _.bind(handler, this)
        this.listenTo(object, events, bound)
        bound()

Lanes.Models.State = Lanes.lib.MakeBaseClass( Lanes.Vendor.Ampersand.State, State )

# ------------------------------------------------------------------ #
# The BasicModel is just a very thin layer over State                #
# ------------------------------------------------------------------ #
class BasicModel
    constructor: -> super
    isModel: true
    isPersistent: ->
        false

    # Check if an attribute named "name" can be set to "value"
    # Returns an empty string if value, and an appropriate error message if not
    checkValid: (name, value) ->
        return '' unless def = this._definition[name]
        if def.required && _.isEmpty(value)
            "Cannot be empty"
        else
            ''

    # sets the model from a user interaction
    # subviews may override this to provide a custom implementation
    setFromView: (key, value) ->
        this.set(key, value)

    # True if the model has "name" as eitehr a prop or session attribute
    hasAttribute: (name) ->
        !! (this._definition[name] || this._derived[name])

Lanes.Models.BasicModel = State.extend( BasicModel )

Lanes.Models.Base = BasicModel.extend( BaseModel )
