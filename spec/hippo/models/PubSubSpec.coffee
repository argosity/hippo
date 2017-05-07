describe "Hippo.Model.PubSub", ->

    beforeEach ->
        @Model = Hippo.Test.defineModel({
            props: { id: 'integer', foo: 'string' }
        })
        @model = new @Model({ id: 1, foo: 'bar' })
        @getModelConfig = ->
            Hippo.Models.PubSub.types.get('/s').records[1]

    it "checks in/out a model when it binds to a view", (done) ->
        spyOn(Hippo.Models.PubSub, 'add').and.callThrough()
        spyOn(Hippo.Models.PubSub, 'remove')
        component = Hippo.Test.makeComponent({}, model: @model)
        _.defer =>
            expect(Hippo.Models.PubSub.add).toHaveBeenCalledWith(@model)
            component.modelBindings.destroy()
            expect(Hippo.Models.PubSub.remove).toHaveBeenCalledWith(@model)
            done()

    it "can retrieve a model after checkin", ->
        record = new @Model(id: 11, foo: 'bar')
        Hippo.Models.PubSub.add(record)
        checkin = Hippo.Models.PubSub.instanceFor(@Model, 11)
        expect(checkin).toEqual(record)

    it 'only adds an identical model once', ->
        Hippo.Models.PubSub.add(@model)
        Hippo.Models.PubSub.add(@model)
        configs = @getModelConfig()
        expect(configs.models.length).toEqual(1)
        expect(configs.models[0].count).toEqual(2)

    it 'does not cause errors to remove a non-added model', ->
        expect( =>
            Hippo.Models.PubSub.remove(@model)
        ).not.toThrowError()

    it 'removes models', ->
        Hippo.Models.PubSub.add(@model)
        configs = Hippo.Models.PubSub.types.get('/s').records[1].models
        expect(configs.length).toEqual(1)
        Hippo.Models.PubSub.remove(@model)
        expect(configs[0].count).toEqual(1)
        Hippo.Models.PubSub.remove(@model)
        expect( Hippo.Models.PubSub.types.get('/s').records[1] ).toBeUndefined()

    it 'subscribes only once when models are added', ->
        Hippo.Models.PubSub.add(@model)
        expect(Hippo.Models.PubSub.mb.subscribe).toHaveBeenCalledWith(
            '/s/1', jasmine.any(Function)
        )
        Hippo.Models.PubSub.add( new @Model({ id: 1, foo: 'foo' }) )
        Hippo.Models.PubSub.add( new @Model({ id: 1, foo: 'baz' }) )
        expect(Hippo.Models.PubSub.mb.subscribe.calls.count()).toEqual(1)

    it 'unsubcribes only when all models are removed', ->
        for i in [0..2]
            Hippo.Models.PubSub.add(@model)
        newModel = new @Model({ id: 1, foo: 'foo' })
        Hippo.Models.PubSub.add( newModel )
        # note - over unsubscribed
        for i in [0..3]
            Hippo.Models.PubSub.remove(@model)
        expect(@getModelConfig().models.length).toEqual(1)
        expect(Hippo.Models.PubSub.mb.subscribe.calls.count()).toEqual(1)
        expect(Hippo.Models.PubSub.mb.unsubscribe.calls.count()).toEqual(0)
        Hippo.Models.PubSub.remove(newModel)
        Hippo.Models.PubSub.remove(newModel)
        expect(@getModelConfig()).toBeUndefined()
        expect(Hippo.Models.PubSub.mb.unsubscribe.calls.count()).toEqual(1)
