describe "Lanes.Models.Collection", ->


    it "it triggers promise on loading", (done) ->
        Model = Lanes.Test.defineModel
            props: { id: 'integer', title: 'string' }

        syncSucceedWith([
            { id: 1, title: 'first value'  }
            { id: 2, title: 'second value' }
        ])
        collection = Model.where(name: 'foo')
        expect(collection.requestInProgress).toBe(true)
        collection.whenLoaded ->
            expect( collection.isLoaded() ).toEqual( true )
            done()

    it "triggers length when changed", ->
        Model = Lanes.Test.defineModel
            props: { id: 'integer', title: 'string' }

        collection = new Model.Collection
        spy = jasmine.createSpy('onLengthChange')
        collection.on("change:length", spy)
        model = collection.add({ id: 1, title: 'first' })
        expect(spy).toHaveBeenCalled()
        spy.calls.reset()
        collection.remove(model)
        expect(spy).toHaveBeenCalled()
        spy.calls.reset()
        collection.reset([{ id:11, title: 'last'}])
        expect(spy).toHaveBeenCalled()

    it "reads from caches", (done) ->
        model = Lanes.Test.makeModel({
            cacheDuration: [1, 'day']
            api_path: 'model-cache'
            props: { id: 'integer', title: 'string' }
        }, {id: 1})
        Lanes.Models.ServerCache.CACHE["/model-cache"] = [
            { id: 1, title: 'first value'  }
            { id: 2, title: 'second value' }
        ]
        collection = new model.constructor.Collection
        collection.fetch().then ->
            expect(collection.length).toEqual(2)
            expect(collection.first().title).toEqual('first value')
            done()
