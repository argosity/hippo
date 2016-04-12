describe "Lanes.Model.PubSub", ->

    beforeEach ->
        @Model = Lanes.Test.defineModel({
            props: { id: 'integer', foo: 'string' }
        })
        @model = new @Model({ id: 1, foo: 'bar' })
        @getModelConfig = ->
            Lanes.Models.PubSub.types.get('/s').records[1]

    it "checks in/out a model when it binds to a view", ->
        spyOn(Lanes.Models.PubSub, 'add').and.callThrough()
        spyOn(Lanes.Models.PubSub, 'remove')
        component = Lanes.Test.makeComponent({}, model: @model)
        expect(Lanes.Models.PubSub.add).toHaveBeenCalledWith(@model)
        component.data.destroy()
        expect(Lanes.Models.PubSub.remove).toHaveBeenCalledWith(@model)

    it "can retrieve a model after checkin", ->
        record = new @Model(id: 11, foo: 'bar')
        Lanes.Models.PubSub.add(record)
        checkin = Lanes.Models.PubSub.instanceFor(@Model, 11)
        expect(checkin).toEqual(record)

    it 'only adds an identical model once', ->
        Lanes.Models.PubSub.add(@model)
        Lanes.Models.PubSub.add(@model)
        configs = @getModelConfig()
        expect(configs.models.length).toEqual(1)
        expect(configs.models[0].count).toEqual(2)

    it 'does not cause errors to remove a non-added model', ->
        expect( =>
            Lanes.Models.PubSub.remove(@model)
        ).not.toThrowError()


    it 'removes models', ->
        Lanes.Models.PubSub.add(@model)
        configs = Lanes.Models.PubSub.types.get('/s').records[1].models
        expect(configs.length).toEqual(1)

        Lanes.Models.PubSub.remove(@model)
        expect(configs[0].count).toEqual(1)
        Lanes.Models.PubSub.remove(@model)
        expect( Lanes.Models.PubSub.types.get('/s').records[1] ).toBeUndefined()

    it 'subscribes only once when models are added', ->
        Lanes.Models.PubSub.add(@model)
        expect(Lanes.Models.PubSub.mb.subscribe).toHaveBeenCalledWith(
            '/s/1', jasmine.any(Function)
        )
        Lanes.Models.PubSub.add( new @Model({ id: 1, foo: 'foo' }) )
        Lanes.Models.PubSub.add( new @Model({ id: 1, foo: 'baz' }) )
        expect(Lanes.Models.PubSub.mb.subscribe.calls.count()).toEqual(1)

    it 'unsubcribes only when all models are removed', ->
        for i in [0..2]
            Lanes.Models.PubSub.add(@model)
        newModel = new @Model({ id: 1, foo: 'foo' })
        Lanes.Models.PubSub.add( newModel )
        # note - over unsubscribed
        for i in [0..3]
            Lanes.Models.PubSub.remove(@model)
        expect(@getModelConfig().models.length).toEqual(1)
        expect(Lanes.Models.PubSub.mb.subscribe.calls.count()).toEqual(1)
        expect(Lanes.Models.PubSub.mb.unsubscribe.calls.count()).toEqual(0)
        Lanes.Models.PubSub.remove(newModel)

        Lanes.Models.PubSub.remove(newModel)

        expect(@getModelConfig()).toBeUndefined()
        expect(Lanes.Models.PubSub.mb.unsubscribe.calls.count()).toEqual(1)
