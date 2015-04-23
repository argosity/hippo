# ------------------------------------------------------------------ #
# Handles Association definitions.                                   #
# It creates a derived definition for each one                       #
# and contains utility functions to operate on them                  #
# ------------------------------------------------------------------ #
class Lanes.Models.AssocationMap
    constructor: (@klass)->
        @klass::derived ||= {}
        @definitions = @klass::associations
        @definitions['created_by'] ||= { model: 'Lanes.Models.User', readOnly: true }
        @definitions['updated_by'] ||= { model: 'Lanes.Models.User', readOnly: true }
        for name, options of @definitions
            @klass::derived[name] = this.derivedDefinition(name,options)

    getClassFor: (name)->
        definition = @definitions[name]
        object = definition.model || definition.collection
        Lanes.u.findObject(object, 'Models', @klass::FILE)

    getOptions: (name, definition, model)->
        options = { parent: model }
        if definition.options
            _.extend(options, Lanes.u.resultsFor(model,definition.options))
        options

    # will be called in the scope of the parent model
    createModel: (association, name, definition, fk, pk, target_class)->
        target_class ||= association.getClassFor(name)
        options = association.getOptions(name,definition,this)
        model_id = this.get(pk)
        if model_id && model_id == this._cache[name]?.id
            this._cache[name]
        else
            target_class.findOrCreate(options)

    # will be called in the scope of the parent model
    createCollection: (association, name, definition, fk, pk, target_class)->
        target_class ||= association.getClassFor(name)
        options = association.getOptions(name,definition,this)
        options.filter ||= {}
        options.filter[fk]=this.get(pk)

        if target_class::isCollection
            new target_class(options.models||[],options)
        else
            options.model=target_class
            new Lanes.Models.AssociationCollection(options.models||[],options)
    # returns the definition for the derived property
    derivedDefinition: (name,definition)->
        defaultCreator=if definition.model then this.createModel else this.createCollection
        args = [ this, name, definition, this.fk(name), this.pk(name) ]
        createFn = if definition.default
            -> definition.default.apply(this,args) || defaultCreator.apply(this,args)
        else
            defaultCreator
        { deps: [this.pk(name)], fn: _.partial(createFn, args...) }


    # Sets the assocations for "model"
    set: (model, data)->
        this._set(model, data, 'set')

    setFromServer: (model, data)->
        this._set(model, data, 'setFromServer')

    _set: (model, data, fn_name)->
        for name, value of data
            if @definitions[name]
                attributes = if _.isFunction(value.serialize) then value.serialize() else value
                association = model[name]
                association[fn_name]( attributes )
                # if we're replaceing the model's contents with another, copy the dirty status as well
                if association.isModel
                    model.set(this.pk(name), association.id) unless association.isNew
                    association.isDirty = value.isDirty if value.isModel

    pk: (name)->
        def = @definitions[name]
        return null unless name
        def.pk || ( if def.model then "#{name}_id" else "id" )

    fk: (name)->
        def = @definitions[name]
        return null unless name
        def.fk || ( if def.model then "id" else "#{name}_id" )

    # returns the data from all assocations for saving
    dataForSave: (model,options)->
        ret = {}
        options.saveDepth = ( if options.saveDepth then options.saveDepth+1 else 1 )
        return ret if options.saveDepth > 5
        for name, options of @definitions
            unless options.readOnly
                data = model[name].dataForSave(options)
                unless _.isEmpty( data )
                    ret[name] = data

        ret

    # return a list of assocations from "name" that are not loaded
    nonLoaded: (model, names)->
        list = []
        for name in names
            if _.has(@definitions, name) && model[name].isNew()
                list.push(name)
        list
