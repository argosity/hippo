describe "Lanes.React.DataMixin", ->

    it "fires forceUpdate for a model", ->
        model = Lanes.Test.makeModel
            props:
                id: 'integer'
                foo: 'string'
        comp = Lanes.Test.makeComponent({}, model: model)
        spyOn(comp, 'forceUpdate')
        model.foo = "bar"
        expect(comp.forceUpdate).toHaveBeenCalled()

    it "fires forceUpdate for a collection", ->
        collection = Lanes.Test.makeCollection()
        comp = Lanes.Test.makeComponent({}, collection: collection)
        spyOn(comp, 'forceUpdate')
        collection.add([{}])
        expect(comp.forceUpdate).toHaveBeenCalled()

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
            bindEvents:
                model: 'change:bar'
        }, {
            model: model
        })
        spyOn(comp, 'forceUpdate')
        model.foo = "bar"
        expect(comp.forceUpdate).not.toHaveBeenCalled()
        model.bar = "foo"
        expect(comp.forceUpdate).toHaveBeenCalled()

    it "can rebind events", ->
        Model = Lanes.Test.defineModel
            props:
                foo: 'string', bar: 'string'
        m1 = new Model
        m2 = new Model
        comp = Lanes.Test.makeComponent({}, {
            model: m1
        })
        spyOn(comp, 'forceUpdate')
        m1.foo = "bar"
        expect(comp.forceUpdate).toHaveBeenCalled()

        comp.modelBindings.reset(model: m2)
        comp.forceUpdate.calls.reset()

        m1.foo = "a different bar"
        expect(comp.forceUpdate).not.toHaveBeenCalled()
        m2.foo = "bar"
        expect(comp.forceUpdate).toHaveBeenCalled()
