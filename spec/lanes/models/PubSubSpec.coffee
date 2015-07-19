describe "Lanes.Model.PubSub", ->

    it "checks in/out a model when it binds to a view", ->
        spyOn(Lanes.Models.PubSub, 'add').and.callThrough()
        spyOn(Lanes.Models.PubSub, 'remove')
        model = Lanes.Test.makeModel({
            props: { id: 'integer', foo: 'string' }
        }, { id: 1, foo: 'bar' })
        component = Lanes.Test.makeComponent({}, model: model)
        expect(Lanes.Models.PubSub.add).toHaveBeenCalledWith(model)
        component.data.destroy()
        expect(Lanes.Models.PubSub.remove).toHaveBeenCalledWith(model)

    it "can retrieve a model after checkin", ->
        Model = Lanes.Test.defineModel({
            props: { id: 'integer', foo: 'string' }
        })

        record = new Model(id: 11, foo: 'bar')

        Lanes.Models.PubSub.add(record)
        checkin = Lanes.Models.PubSub.instanceFor(Model, 11)
        expect(checkin).toEqual(record)
