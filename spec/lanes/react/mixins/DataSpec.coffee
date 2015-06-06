describe "Lanes.React.DataMixin", ->

    it "fires setState for a model", ->
        model = Lanes.Test.makeModel
            props:
                id: 'integer'
                foo: 'string'
        comp = Lanes.Test.makeComponent({}, model: model)
        spyOn(comp, 'setState')
        model.foo = "bar"
        expect(comp.setState).toHaveBeenCalledWith( model: model )

    it "fires setState for a collection", ->
        collection = Lanes.Test.makeCollection()
        comp = Lanes.Test.makeComponent({}, collection: collection)
        spyOn(comp, 'setState')
        collection.add([{}])
        expect(comp.setState).toHaveBeenCalledWith( collection: collection )

    it "obeys global pubsub settings", ->
        spyOn(Lanes.Models.PubSub, 'add').and.callThrough()
        model = Lanes.Test.makeModel({
            props: { id: 'integer', foo: 'string' }
        }, { id: 1, foo: 'bar' })
        component = Lanes.Test.makeComponent({pubsub: false}, model: model)
        expect(Lanes.Models.PubSub.add).not.toHaveBeenCalled()

    it "obeys per-object pubsub settings", ->
        spyOn(Lanes.Models.PubSub, 'add').and.callThrough()
        model = Lanes.Test.makeModel({
            props: { id: 'integer', foo: 'string' }
        }, {id: 1, foo: 'bar' })

        component = Lanes.Test.makeComponent({pubsub: {model: false}}, model: model)
        expect(Lanes.Models.PubSub.add).not.toHaveBeenCalled()

    it "can listen to only specific events", ->
        model = Lanes.Test.makeModel
            props:
                foo: 'string'
                bar: 'string'
        comp = Lanes.Test.makeComponent({
            bindDataEvents:
                model: 'change:bar'
        }, {
            model: model
        })
        spyOn(comp, 'setState')
        model.foo = "bar"
        expect(comp.setState).not.toHaveBeenCalled()
        model.bar = "foo"
        expect(comp.setState).toHaveBeenCalledWith( model: model )

    it "can rebind events", ->
        Model = Lanes.Test.defineModel
            props:
                foo: 'string', bar: 'string'
        m1 = new Model
        m2 = new Model
        comp = Lanes.Test.makeComponent({}, {
            model: m1
        })
        spyOn(comp, 'setState')
        m1.foo = "bar"
        expect(comp.setState).toHaveBeenCalled()

        comp.data.rebind(model: m2)
        comp.setState.calls.reset()
        m1.foo = "a different bar"
        expect(comp.setState).not.toHaveBeenCalled()
        m2.foo = "bar"
        expect(comp.setState).toHaveBeenCalled()
