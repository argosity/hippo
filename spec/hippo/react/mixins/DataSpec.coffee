describe "Hippo.React.DataMixin", ->

    it "fires forceUpdate for a model", ->
        model = Hippo.Test.makeModel
            props:
                id: 'integer'
                foo: 'string'
        comp = Hippo.Test.makeComponent({}, model: model)
        spyOn(comp, 'forceUpdate')
        model.foo = "bar"
        expect(comp.forceUpdate).toHaveBeenCalled()

    it "fires forceUpdate for a collection", ->
        collection = Hippo.Test.makeCollection()
        comp = Hippo.Test.makeComponent({}, collection: collection)
        spyOn(comp, 'forceUpdate')
        collection.add([{}])
        expect(comp.forceUpdate).toHaveBeenCalled()

    it "obeys global pubsub settings", ->
        spyOn(Hippo.Models.PubSub, 'add').and.callThrough()
        model = Hippo.Test.makeModel({
            props: { id: 'integer', foo: 'string' }
        }, { id: 1, foo: 'bar' })
        component = Hippo.Test.makeComponent({pubsub: false}, model: model)
        expect(Hippo.Models.PubSub.add).not.toHaveBeenCalled()

    it "obeys per-object pubsub settings", ->
        spyOn(Hippo.Models.PubSub, 'add').and.callThrough()
        model = Hippo.Test.makeModel({
            props: { id: 'integer', foo: 'string' }
        }, {id: 1, foo: 'bar' })

        component = Hippo.Test.makeComponent({pubsub: {model: false}}, model: model)
        expect(Hippo.Models.PubSub.add).not.toHaveBeenCalled()

    it "can listen to only specific events", ->
        model = Hippo.Test.makeModel
            props:
                foo: 'string'
                bar: 'string'

        comp = Hippo.Test.makeComponent({
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
        Model = Hippo.Test.defineModel
            props:
                foo: 'string', bar: 'string'
        m1 = new Model
        m2 = new Model
        comp = Hippo.Test.makeComponent({}, {
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
