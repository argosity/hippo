describe "Hippo.Models.Collection", ->


    it "it triggers promise on loading", (done) ->
        Model = Hippo.Test.defineModel
            props: { id: 'integer', title: 'string' }

        LT.syncSucceedWith([
            { id: 1, title: 'first value'  }
            { id: 2, title: 'second value' }
        ])
        collection = Model.where(name: 'foo')
        expect(collection.requestInProgress).toBeDefined()
        collection.whenLoaded ->
            expect( collection.isLoaded() ).toBe(true)
            done()

    it "triggers length when changed", ->
        Model = Hippo.Test.defineModel
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
