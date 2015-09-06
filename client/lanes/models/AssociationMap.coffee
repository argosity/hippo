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
        @collections = {}
        for name, options of @definitions
            @klass::derived[name] = this.derivedDefinition(name, options)

    getClassFor: (name) ->
        definition = @definitions[name]
        object = definition.model || definition.collection
        Lanes.u.findObject(object, 'Models', @klass::FILE)

    getOptions: (name, model) ->
        definition = @definitions[name]
        options = { parent: model }
        if definition.options
            _.extend(options, Lanes.u.resultsFor(model, definition.options))
        options

    # will be called in the scope of the parent model
    createModel: (association, name, definition, fk, pk, target_class) ->
        target_class ||= association.getClassFor(name)
        options = association.getOptions(name, this)
        model_id = this.get(pk)
        if model_id && model_id == this._cache[name]?.id
            this._cache[name]
        else
            new target_class(options)

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

    # will be called in the scope of the parent model
    createCollection: (association, name, definition, fk, pk, target_class) ->
        target_class ||= association.getClassFor(name)
        options = association.getOptions(name, this)
        options.filter ||= {}
        options.filter[fk] = this.get(pk)

        if true == target_class::isCollection
            new target_class(options.models || [], options)
        else
            options.model = target_class
            new Lanes.Models.AssociationCollection(options.models || [], options)

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
            if @definitions[name] && Lanes.u.isModel(value) && !value.isNew()
                model[@pk(name)] = if value then value.getId() else null

    setFromServer: (model, data, options) ->
        this._set(model, data, options, 'setFromServer')

    _set: (model, data, options, fn_name) ->
        for name, value of data
            continue unless @definitions[name]
            association = model[name]
            attributes = if _.isFunction(value.serialize) then value.serialize() else value
            association[fn_name]( attributes )
            if Lanes.u.isModel(association)
                model.set(this.pk(name), association.id) unless association.isNew()
                model.trigger("change:#{name}", association, {}) unless options?.silent
                association.isDirty = if value.isDirty? then value.isDirty else true
                unless _.isObject(value)
                    association.clear()
                    continue

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
        for name, options of @definitions
            continue if options.readOnly
            assoc = model[name]
            ret[name] = assoc.dataForSave(options) if _.result(assoc, 'isDirty')
        ret

    serialize: (model, options = {depth: 1}) ->
        ret = {}
        return ret if options.depth > 5
        for name, options of @definitions
            ret[name] = model[name].serialize()
        ret

    # return a list of assocations from "name" that are not loaded
    nonLoaded: (model, names) ->
        list = []
        for name in names
            if _.has(@definitions, name) && (Lanes.u.isCollection(model[name]) || model[name].isNew())
                list.push(name)
        list
