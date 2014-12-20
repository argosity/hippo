
describe "PubSub Suite", ->
        
    it "checks in/out a model when it binds to a view", ->
        view  = new Lanes.Testing.View
        model = new Lanes.Testing.Model(id:1)
        spyOn(Lanes.Data.PubSub,'add').and.callThrough()
        spyOn(Lanes.Data.PubSub,'remove')
        view.model = model
        expect(Lanes.Data.PubSub.add).toHaveBeenCalledWith(model)
        expect(Lanes.Vendor.MessageBus.subscribe)
            .toHaveBeenCalledWith("/test/1", jasmine.any(Function))
        view.unset('model')
        expect(Lanes.Data.PubSub.remove).toHaveBeenCalledWith(model)

    it "can retrieve a model after checkin", ->
        model = new Lanes.Testing.Model(id: 11, name:'bar')
        Lanes.Data.PubSub.add(model)
        checkin = Lanes.Data.PubSub.instanceFor(Lanes.Testing.Model, 11)
        expect(checkin).toEqual(model)
        
