
describe "Model Suite", ->
    Model = undefined
    Collection = undefined
    class Color
        constructor: -> super
        props: { id: 'integer', rgb: 'string' }
    Lanes.Data.Model.extend(Color)

    makeModel = (props,args={})->
        _.extend(Model.prototype, props)
        Lanes.Data.Model.extend(Model)
        Collection::model = Model
        Lanes.Data.Collection.extend(Collection)
        collection = new Collection
        return collection.add(new Model(args))

    beforeEach ->
        class TestModel
            constructor: -> super
        Model = TestModel
        class TestCollection
            constructor: -> super
        Collection = TestCollection

        
    it "tracks unsaved attributes", ->
        model = makeModel({
            session:
                foo: 'string'
                bar: 'integer'
            props:
                saved: 'string'
        }, {bar: 'baz'})
        expect(model.isDirty()).toBeFalse()
        model.foo = 'baz' # session prop
        expect(model.isDirty()).toBeFalse()
        expect(model.unsavedData()).toBeEmptyObject()
        model.set( saved: 'true' )
        expect(model.isDirty()).toBeTrue()

        
    it "can tell if it has attributes", ->
        model = makeModel({
            session:
                foo: 'string'
            props:
                bar: 'string'
        })
        expect(model.hasAttribute('missing')).toBeFalse()
        expect(model.hasAttribute('foo')).toBeTrue()
        expect(model.hasAttribute('bar')).toBeTrue()

    it "provides data for saving", ->
        # model with other types of data, but should only save "props"
        model = makeModel({
            associations:
                color:{ model: Color }
            session:
                unsaved: 'string'
            props:
                id: 'integer'
                foo: 'string'
                bar: 'string'
            derived:
                atest:
                    fn: -> 'blarg'
                
        })
        model.set( id: 10, unsaved: 'falsify', color: { rgb: '99FFFF' } )

        expect( model.dataForSave() ).toEqual( id: 10, color: { rgb: '99FFFF' } )
        model.foo = 'a value'
        a=model.changeMonitor.changedAttributes()
        expect( model.dataForSave() ).toEqual( id: 10, foo: 'a value', color: { rgb: '99FFFF' } )

    it "can be saved", ->
        model = makeModel({
            props:
                id: 'integer'
                foo: 'string'
                bar: 'string'
                
        }, { foo: 'one, two, three'} )
        expect(model.isDirty()).toBeTrue()
        expect(model.unsavedData()).toEqual( foo: 'one, two, three' )
        model.save()
        expect(model.sync).toHaveBeenCalledWith('create', model, jasmine.any(Object))
        model.id=11
        expect(model.isNew()).toBeFalse()
        model.sync.calls.reset()
        syncSucceedWith({
            foo: 'a new foo value'
        })
        model.save()
        expect(model.sync).toHaveBeenCalledWith('patch', model, jasmine.any(Object))
        expect(model.foo).toEqual('a new foo value')

    it "can be fetched",->
        model = makeModel({
            props:
                { id: 'integer', foo: 'string' }
        })
        syncSucceedWith({
            foo: 'foo value'
        })
        model.fetch()
        expect(model.sync).toHaveBeenCalledWith('read', model, jasmine.any(Object))
        expect(model.foo).toEqual('foo value')
        options = model.sync.lastOptions()
        expect(options).toHaveTrue('ignoreUnsaved')
        expect(options).toHaveNumberWithinRange('limit',1,1)


    it "can be destroyed", ->
        model = makeModel({
            props: { id: 'integer' }
        },{ id: 1 })
        collection = model.collection
        expect(collection.length).toEqual(1)
        model.destroy()
        expect(model.sync)
            .toHaveBeenCalledWith('delete', model, jasmine.any(Object))
        expect(collection.length).toEqual(0)

    it "sets associations", ->
        model = makeModel({
            associations:
                color:{ model: Color }
            props: { id: 'integer', foo: 'string' }
        },{ id: 1 })
        expect(model.color).toBeObject()
        model.set(color: { rgb: '99FFFF' })
        expect(model.color.rgb).toEqual('99FFFF')
        model.setFromResponse(color:{ rgb: 'FFA500' })
        expect(model.color.rgb).toEqual('FFA500')

    it "can fetch associations", ->
        model = makeModel({
            associations:
                color:{ model: Color }
            props: { id: 'integer', foo: 'string' }
        },{ id: 1 })
        model.withAssociations('color')
        expect(model.sync).toHaveBeenCalledWith('read', model, jasmine.any(Object))
        options = model.sync.lastOptions()
        expect(options.include).toEqual(['color'])
        
    it "assigns an inverse collection property", ->
        model = makeModel({})
        expect(Model::Collection).toEqual(Collection)
    
