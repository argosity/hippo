describe "Lanes.Models.AssocationProxy", ->

    class Color
        constructor: -> super
        api_path: -> 'test'
        props: { id: 'integer', model_fk_id: 'integer', rgb: 'string' }
        testFunc: (arg) -> @rgb = arg
    Lanes.Models.Base.extend(Color)

    beforeEach ->
        @Model = Lanes.Test.defineModel({
            associations:
                color:{ model: Color }
                colors: { collection: Color, fk: 'model_fk_id' }
            props: { id: 'integer', property: 'string' }
            session: { session: 'string' }
            derived:
                dr: { fn: -> 'dr' }
        })
        @Proxy = Lanes.Models.AssocationProxy.construct(@Model)

    it "proxies the associations with other proxies", ->
        instance = new @Proxy
        expect(instance.color.isProxy).toBe(true)
        expect(instance.color.id).toBeNull()

    it 'can create a real association and return it if needed', ->
        instance = new @Proxy
        expect(instance.color.isProxy).toBe(true)
        instance.color.rgb = 'foo'
        expect(instance.color.isProxy).toBeUndefined()
        expect(instance.color).toEqual(jasmine.any(Color))

    it 'can proxy derived properties', ->
        instance = new @Proxy
        expect(instance.dr).toBeNull()

    it 'raises error when writing to derived properties', ->
        instance = new @Proxy
        expect(->
            instance.dr = 'foo'
        ).toThrowError(TypeError)

    it 'instantiates and forwards function calls', ->
        instance = new @Proxy
        instance.color.testFunc('1234')
        expect(instance.color).toEqual(jasmine.any(Color))
        expect(instance.color.rgb).toEqual('1234')

    it 'intercepts dataForSave', ->
        instance = new @Proxy
        instance.color.rgb = 'mycolor'
        expect(instance.dataForSave()).toEqual(color: {rgb: 'mycolor'})

    it 'provides api_key', ->
        instance = new @Proxy
        expect(instance.api_path()).toEqual('/s')

    it 'stores events and eventually sets them on model', ->
        spy1 = jasmine.createSpy()
        spy2 = jasmine.createSpy()
        instance = new @Proxy
        instance.color.on('change:rgb', spy1)
        instance.color.once('change:rgb', spy2)
        expect(instance.color.isProxy).toBe(true)
        instance.color.rgb = 'newcolor'
        expect(instance.color.isProxy).toBeUndefined()

        expect(spy1).toHaveBeenCalled()
        expect(spy2).toHaveBeenCalled()

    it 'fires onreplace', ->
        spy = jasmine.createSpy()
        instance = new @Proxy
        instance.on('proxyreplace', spy)
        instance.session = 'foo'
        expect(spy).toHaveBeenCalled()
