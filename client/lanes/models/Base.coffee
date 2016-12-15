# These prototype properties are also
# set on any Collections that are created
PROPERTIES_SHARED_WITH_DEFAULT_COLLECTION = [

]

# Da Model. Handles all things dataish
class BaseModel
    isModel: true
    session:
        errors: 'object'
        changes: { type: 'collection', setOnce: true }
        lastServerMessage: { type: 'string' }
        isDirty:   { type: 'boolean', default: false }
        invalidAttributes: 'array'
        updatingFromChangeset: { type: 'boolean', default: false }

    derived:
        isSavable:
            deps: ['invalidAttributes'], fn: ->
                _.isEmpty @invalidAttributes

        hasErrors:
            deps: ['errors'], fn: -> not _.isEmpty(@errors)

        errorMessage:
            deps:['errors'], fn: ->
                if !@errors then ''
                else if @errors.exception then @errors.exception
                else  _.toSentence( _.map(@errors, (value, key) ->
                    _.titleize(_.humanize(key)) + ' ' + value
                ))
    constructor: (attrs, options = {}) ->
        super
        @on('change', @_calculateInvalidAttributes)
        @_calculateInvalidAttributes()
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
        this.set('updatingFromChangeset', true, silent: true)
        this.set( change.value() )
        for name, value of change.value()
            this.trigger("remote-update:#{name}", this, change)
        this.triggerChangeSet(this, change)
        this.set('updatingFromChangeset', false, silent: true)

    triggerChangeSet: (triggered, change) ->
        this.changes ||= new Lanes.Models.ChangeSet.Collection( parent: this )
        this.changes.add(change)
        this.trigger('remote-update', triggered, change)
        @parent?.triggerChangeSet?(triggered, change)

    modelTypeIdentifier: ->
        _.dasherize(_.last(@FILE?.path || ''))

    extensionIdentifier: ->
        @FILE.extension.identifier

    api_path: ->
        id = @FILE?.extension.identifier
        ( if id then "/#{id}" else '' ) + '/' + _.pluralize(@modelTypeIdentifier())

    urlRoot: ->
        Lanes.config.api_path + _.result(this, 'api_path')

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

    clear: ->
        this.associations?.clear(@)
        super

    # duplicate the model.  Copies only attributes, not bound events
    clone: ->
        new @constructor( @clonedAttributes() )

    clonedAttributes: ->
        attributes = @serialize()
        _.extend(attributes, @getAttributes(session: true, derived: false) )

    attributeType: (name) ->
        @_definition[name].type

    serialize: (options = {}) ->
        options.depth ||= 1
        return if options.depth > 5
        depth = options.depth + 1
        options = _.extend({}, options, {depth})
        _.extend(super,
            this.associations?.serialize(this, options)
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
    setFromServer: (data, options, method) ->
        data = if _.isArray(data) then data[0] else data
        BaseModel.__super__.set.call(this, data )
        @unset('errors')
        this.associations?.setFromServer(this, data, options, method)
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
        options = _.extend({}, original_options, {limit:1, ignoreUnsaved:true})
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
            @changeMonitor?.changedAttributes() || {} ) )
        unless _.isEmpty(attrs) or @isNew()
            attrs[@idAttribute] = this.getId()
        attrs

    # returns data to save to server.  If options.saveAll is true,
    # all data is returned.  Otherwise only unsaved attributes (and associations)
    # are returned.
    dataForSave: (options = {}) ->
        if options.saveAll || this.isNew()
            data = this.getAttributes(props:true, true)
        else
            data = this.unsavedAttributes()
        if this.associations && !options.excludeAssociations
            # empty associations are not included
            associationData = this.associations.dataForSave(this, options)
            _.extend(data, associationData)
            # if submitting associations, we must include our id so they can be updated
            unless this.isNew() or _.isEmpty(associationData)
                data[@idAttribute] = this.getId()

        data

    unCacheDerived: (name) ->
        delete this._cache[name]

    # True if the model has "name" as either a prop, session, or derived attribute
    hasAttribute: (name) ->
        !! (this._definition[name] || this._derived[name])

    # Uses Lanes.Models.Sync by default
    sync: (options...) ->
        Lanes.Models.Sync.state(options...)

    # Check if an attribute named "name" is invalid
    # Returns an empty string if valid, and an appropriate error message if not
    invalidMessageFor: (name) ->
        if @shouldCheckFieldValidity(name) and @isBlank(name)
            "Cannot be empty"
        else
            ''
    shouldCheckFieldValidity: (name) ->
        @unmaskedInvalidFields and
            _.includes(@requiredAttributes, name) and
            _.includes(@unmaskedInvalidFields, name)

    maskInvalidFields: ->
        delete @unmaskedInvalidFields

    unmaskInvalidField: (attr) ->
        if attr is 'all'
            @unmaskedInvalidFields = 'all'
            @trigger("invalid-fields", this, @unmaskedInvalidFields)
        else if @unmaskedInvalidFields isnt 'all'
            @unmaskedInvalidFields ||= []
            if _.includes(@requiredAttributes, attr) and !_.includes(@unmaskedInvalidFields, attr)
                @unmaskedInvalidFields.push(attr)

                @trigger("invalid-field:#{attr}", this)

    _calculateInvalidAttributes: ->
        invalid = []
        for name in @requiredAttributes
            invalid.push(name) if @isBlank(name)
        @invalidAttributes = invalid

    # When the model is extended it auto-creates the created_at and updated_at
    # and sets up the AssociationMap
    @extended: (klass) ->
        return if klass::abstractClass
        klass::props   ||= {}
        klass::session ||= {}

        klass::session['created_at'] ||= 'date'
        klass::session['updated_at'] ||= 'date'
        # these columns are included when loaded with the 'with_user_logins' scope
        klass::session['created_by_user.login'] ||= 'string'
        klass::session['updated_by_user.login'] ||= 'string'

        if klass::associations
            klass::associations = new Lanes.Models.AssociationMap(klass)

    @afterExtended: (klass) ->
        return if klass::abstractClass
        attrs = []
        for name, definition of klass::_definition when definition.required
            attrs.push(name)
        for name, definition of (klass::associations?.definitions || {}) when definition.required
            attrs.push(name)
        klass::requiredAttributes = attrs

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


# ------------------------------------------------------------------ #
# The BasicModel is just a very thin layer over State                #
# ------------------------------------------------------------------ #
class BasicModel
    constructor: -> super
    isModel: true
    isPersistent: ->
        false

    isBlank: (name) ->
        return _.isEmpty(this.serialize()) if _.isUndefined(name)
        value = this.get(name)
        _.isBlank(value) || (value.isProxy && value.isNew())


    # sets the model from a user interaction
    # subviews may override this to provide a custom implementation
    setFromView: (key, value) ->
        this.set(key, value)


Lanes.Models.BasicModel = Lanes.Models.State.extend( BasicModel )

Lanes.Models.Base = BasicModel.extend( BaseModel )
