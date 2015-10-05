# ------------------------------------------------------------------ #
# Handles Association definitions.                                   #
# It creates a derived definition for each one                       #
# Note!  An AssociationMap is created for each type of Model, and    #
# is shared between all instances                                    #
# ------------------------------------------------------------------ #
class Lanes.Models.AssocationMap
    constructor: (@klass) ->
        @klass::derived ||= {}
        @definitions = @klass::associations
        @definitions['created_by'] ||= { model: 'Lanes.Models.User', readOnly: true }
        @definitions['updated_by'] ||= { model: 'Lanes.Models.User', readOnly: true }
        @collections = Object.create(null)
        @proxy = Object.create(null)
        for name, options of @definitions
            @klass::derived[name] = this.derivedDefinition(name, options)

    # finds the correct class for association
    getClassFor: (name) ->
        definition = @definitions[name]
        object = definition.model || definition.collection
        Lanes.u.findObject(object, 'Models', @klass::FILE)

    getProxyFor: (name) ->
        @proxy[name] ||= (
            Lanes.Models.AssocationProxy.construct( @getClassFor(name),
                association_name: name
            )
        )

    replaceProxy: (name, model, options) ->
        options.parent._cache[name] = model

    getOptions: (name, model) ->
        definition = @definitions[name]
        options = { parent: model }
        if definition.options
            _.extend(options, Lanes.u.resultsFor(model, definition.options))
        options

    # will be called in the scope of the parent model
    createModel: (association, name, definition, fk, pk, target_class) ->
        #target_class ||= association.getClassFor(name)
        Proxy = association.getProxyFor(name)
        new Proxy( association, association.getOptions(name, @)  )

    # will be called in the scope of the parent model
    createCollection: (association, name, definition, fk, pk, target_class) ->
        target_class ||= association.getClassFor(name)
        options = association.getOptions(name, this)
        options.filter ||= {}
        options.filter[fk] = this.get(pk)

        options.inverse_name = definition.inverse

        if true == target_class::isCollection
            new target_class(options.models || [], options)
        else
            options.model = target_class
            new Lanes.Models.AssociationCollection(options.models || [], options)

    # returns a collection for the given association.
    collectionFor: (name, model, options = {}) ->
        options = _.extend({}, this.getOptions(name, model), options)
        @collections[name] ||= (
            Klass = @getClassFor(name)
            if true == Klass::isModel
                new Lanes.Models.AssociationCollection(options.models || [],
                    _.extend({}, options, model: Klass)
                )
            else
                new Klass(options.models || [], options)
        )

    # returns the definition for the derived property
    derivedDefinition: (name, definition) ->
        defaultCreator = if definition.model then this.createModel else this.createCollection
        args = [ this, name, definition, this.fk(name), this.pk(name) ]
        createFn = if definition.default
            -> definition.default.apply(this, args) || defaultCreator.apply(this, args)
        else
            defaultCreator
        { fn: _.partial(createFn, args...) }

    # Sets the assocations for "model"
    set: (model, data, options) ->
        this._set(model, data, options, 'set')
        for name, value of data
            if @exists(name) && Lanes.u.isModel(value) && !value.isNew()
                model[@pk(name)] = if value then value.getId() else null

    setFromServer: (model, data, options) ->
        this._set(model, data, options, 'setFromServer')

    onIdChange: (model) ->
        for name, def of @definitions
            if def.collection and @isCreated(model, name) and model[name]?.associationFilter
                model[name]?.associationFilter[ @fk(name) ] = model[ @pk(name) ]

    _set: (model, data, options, fn_name) ->
        for name, value of data
            # we're done if we're not setting the association to anything
            # and it's not yet created
            continue if not @exists(name) or (_.isEmpty(value) and not @isCreated(model, name))

            association = model[name]

            if association.isProxy
                association.replaceWithModel(value, association_name: name)
            else if Lanes.u.isModel(association)
                continue if association is value

                model.set(this.pk(name), value.id) unless value.isNew?()
                if Lanes.u.isModel(value)
                    association.copyFrom( value )
                else
                    association[fn_name]( value )

                if options?.silent isnt true and association isnt value
                    model.trigger("change:#{name}", value, {})

                association.isDirty = if value.isDirty? then value.isDirty else true
            else
                if value then association[fn_name]( value ) else association.clear()

    pk: (name) ->
        def = @definitions[name]
        return null unless name and def
        _.result(def, 'pk', ( if def.model then "#{name}_id" else "id" ) )

    fk: (name) ->
        def = @definitions[name]
        return null unless name and def
        _.result(def, 'fk', ( if def.model then "id" else "#{name}_id" ) )

    # returns the data from all assocations for saving
    dataForSave: (model, options) ->
        ret = {}
        options.saveDepth = ( if options.saveDepth then options.saveDepth + 1 else 1 )
        return ret if options.saveDepth > 5
        for name, def_options of @definitions when @isCreated(model, name)
            continue if def_options.readOnly or
                (options.onlyAssociations and not _.include(options.onlyAssociations, name))
            assoc = model[name]
            ret[name] = assoc.dataForSave(
                _.extend({}, options, def_options)
            ) if _.result(assoc, 'isDirty')
        ret

    serialize: (model, options = {depth: 1}) ->
        ret = {}
        options.depth ||= 1
        return ret if options.depth > 5
        for name, opts of @definitions when @isCreated(model, name)
            ret[name] = model[name].serialize(options)
        ret

    # return a list of assocations from "name" that are not loaded
    nonLoaded: (model, names) ->
        list = []
        for name in names
            if @exists(name) && (Lanes.u.isCollection(model[name]) || model[name].isNew())
                list.push(name)
        list

    exists: (name) ->
        _.has(@definitions, name)

    isCreated: (model, name) ->
        !!(@exists(name) and model._cache[name])
