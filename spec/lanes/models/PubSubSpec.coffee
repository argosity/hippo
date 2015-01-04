
describe "Lanes.Model.PubSub", ->
        
    it "checks in/out a model when it binds to a view", ->
        view  = new Lanes.Test.DummyView
        model = new Lanes.Test.DummyModel(id:1)
        spyOn(Lanes.Models.PubSub,'add').and.callThrough()
        spyOn(Lanes.Models.PubSub,'remove')
        view.model = model
        expect(Lanes.Models.PubSub.add).toHaveBeenCalledWith(model)
        expect(Lanes.Vendor.MessageBus.subscribe)
            .toHaveBeenCalledWith("/test/1", jasmine.any(Function))
        view.unset('model')
        expect(Lanes.Models.PubSub.remove).toHaveBeenCalledWith(model)

    it "can retrieve a model after checkin", ->
        model = new Lanes.Test.DummyModel(id: 11, name:'bar')
        Lanes.Models.PubSub.add(model)
        checkin = Lanes.Models.PubSub.instanceFor(Lanes.Test.DummyModel, 11)
        expect(checkin).toEqual(model)
        
