describe "Lanes.Models.Base", ->
    class Color
        constructor: -> super
        props: { id: 'integer', rgb: 'string' }
    Lanes.Models.Base.extend(Color)

    it "tracks unsaved attributes", ->
        model = Lanes.Test.makeModel({
            session:
                foo: 'string'
                bar: 'integer'
            props:
                saved: 'string'
        }, {bar: 'baz'})
        expect(model.isDirty()).toBeFalse()
        model.foo = 'baz' # session prop
        expect(model.isDirty()).toBeFalse()
        expect(model.unsavedAttributes()).toBeEmptyObject()
        model.set( saved: 'true' )
        expect(model.isDirty()).toBeTrue()


    it "can tell if it has attributes", ->
        model = Lanes.Test.makeModel({
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
        model = Lanes.Test.makeModel({
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

    it "can be saved", (done)->
        model = Lanes.Test.makeModel({
            props:
                id: 'integer'
                foo: 'string'
                bar: 'string'

        }, { foo: 'one, two, three'} )
        expect(model.isDirty()).toBeTrue()
        expect(model.unsavedAttributes()).toEqual( foo: 'one, two, three' )
        model.save()
        expect(model.sync).toHaveBeenCalledWith('create', model, jasmine.any(Object))
        model.id=11
        expect(model.isNew()).toBeFalse()
        model.sync.calls.reset()
        syncSucceedWith({
            foo: 'a new foo value'
        })
        model.save().then ->
            expect(model.sync).toHaveBeenCalledWith('patch', model, jasmine.any(Object))
            expect(model.foo).toEqual('a new foo value')
            done()

    it "can be fetched", (done)->
        model = Lanes.Test.makeModel({
            props:
                { id: 'integer', foo: 'string' }
        })
        syncSucceedWith({
            foo: 'foo value'
        })
        model.fetch().then ->
            expect(model.sync).toHaveBeenCalledWith('read', model, jasmine.any(Object))
            expect(model.foo).toEqual('foo value')
            options = model.sync.lastOptions()
            expect(options).toHaveTrue('ignoreUnsaved')
            expect(options).toHaveNumberWithinRange('limit',1,1)
            done()

    it "creates a Collection property even when the base is abstract", ->
        class Base
            constructor: -> super
            abstractClass: true
        Lanes.Models.Base.extend(Base)
        class Model
            constructor: -> super
        Model = Base.extend(Model)
        expect(Model.Collection::model).toEqual(Model)


    it "loads using where", (done)->
        Model = Lanes.Test.DummyModel
        syncSucceedWith([
            { id: 1, title: 'first value'  }
            { id: 2, title: 'second value' }
        ])
        Model.where(title: 'first value').whenLoaded (collection)->
            options = Model::sync.lastOptions()
            expect(options.query).toEqual({title:'first value'})
            expect(collection.length).toEqual(2)
            done()

    it "can be destroyed", (done)->
        model = Lanes.Test.makeModel({
            props: { id: 'integer' }
        },{ id: 1 })
        collection = model.collection
        expect(collection.length).toEqual(1)
        model.destroy().then ->
            expect(model.sync)
                .toHaveBeenCalledWith('delete', model, jasmine.any(Object))
            expect(collection.length).toEqual(0)
            done()

    it "sets associations", ->
        model = Lanes.Test.makeModel({
            associations:
                color:{ model: Color }
            props: { id: 'integer', foo: 'string' }
        },{ id: 1 })
        expect(model.color).toBeObject()
        model.set(color: { rgb: '99FFFF' })
        expect(model.color.rgb).toEqual('99FFFF')
        model.setFromServer(color:{ rgb: 'FFA500' })
        expect(model.color.rgb).toEqual('FFA500')

    it "can fetch associations", ->
        model = Lanes.Test.makeModel({
            associations:
                color:{ model: Color }
            props: { id: 'integer', foo: 'string' }
        },{ id: 1 })
        model.withAssociations('color')
        expect(model.sync).toHaveBeenCalledWith('read', model, jasmine.any(Object))
        options = model.sync.lastOptions()
        expect(options.include).toEqual(['color'])
