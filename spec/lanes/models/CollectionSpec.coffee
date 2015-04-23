describe "Lanes.Models.Collection", ->


    it "it triggers promise on loading", (done)->
        Model = Lanes.Test.DummyModel
        syncSucceedWith([
            { id: 1, title: 'first value'  }
            { id: 2, title: 'second value' }
        ])
        collection = Model.where( name: 'foo' )
        collection.whenLoaded ->
            expect( collection.isLoaded() ).toEqual( true )
            done()

    it "triggers length when changed", ->
        collection = new Lanes.Test.DummyModel.Collection
        spy = jasmine.createSpy('onLengthChange')
        collection.on("change:length", spy)
        model = collection.add({ id: 1, title: 'first' })
        expect(model).toEqual(jasmine.any(Lanes.Test.DummyModel))
        expect(spy).toHaveBeenCalled()
        spy.calls.reset()
        collection.remove(model)
        expect(spy).toHaveBeenCalled()
        spy.calls.reset()
        collection.reset([{ id:11, title: 'last'}])
        expect(spy).toHaveBeenCalled()


    it "caches", (done)->
        model = Lanes.Test.makeModel({
            cacheDuration: [1,'day']
            props: { id: 'integer', title: 'string' }
        })
        syncSucceedWith([
            { id: 1, title: 'first value'  }
            { id: 2, title: 'second value' }
        ])
        collection = new model.constructor.Collection
        collection.fetch().then ->
            expect(collection.length).toEqual 2
            expect(Lanes.Models.Sync.perform).toHaveBeenCalled()
            Lanes.Models.Sync.perform.calls.reset()
            collection.fetch().then ->
                expect(Lanes.Models.Sync.perform).not.toHaveBeenCalled()
                expect(collection.length).toEqual 2
                done()
