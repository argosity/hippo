describe "Lanes.Models.Collection", ->

        
    it "it triggers promise on loading", (done)->
        Model = Lanes.Test.DummyModel
        syncSucceedWith([
            { id: 1, title: 'first value'  }
            { id: 2, title: 'second value' }
        ])
        collection = Model.where( name: 'foo' )
        collection.whenLoaded ->
            expect( collection.isLoaded() ).toBeTrue()
            done()

