describe "Hippo.Models.AssocationProxy", ->


    class Color
        constructor: -> super
        api_path: -> 'test'
        props: { id: 'integer', model_fk_id: 'integer', rgb: 'string' }
        derived:
            rgba: { fn: -> @rgb + 'ff' }
        testFunc: (arg) -> @rgb = arg
    Hippo.Models.Base.extend(Color)

    beforeEach ->
        @Model = Hippo.Test.defineModel({
            associations:
                color:{ model: Color }
                colors: { collection: Color, fk: 'model_fk_id' }
            props:
                id: 'integer'
                color_id: 'integer'
                property: 'string'
            session: { session: 'string' }
        })
        @instance = new @Model

    it "proxies the associations with other proxies", ->
        expect(@instance.color.isProxy).toBe(true)
        expect(@instance.color.id).toBeUndefined()
        @instance.color_id = 42
        expect(@instance.color.id).toEqual(42)
        expect(@instance.color.isProxy).toBe(true)

    it 'can create a real association and return it if needed', ->
        @instance.color.rgb = 'foo'
        expect(@instance.color.isProxy).toBeUndefined()
        expect(@instance.color).toEqual(jasmine.any(Color))

    it 'can proxy derived properties', ->
        expect(@instance.color.rgb).toBeNull()

    it 'raises error when writing to derived properties', ->
        expect(=>
            @instance.color.rgba = 'foo'
        ).toThrowError(TypeError)

    it 'instantiates and forwards function calls', ->
        @instance.color.testFunc('1234')
        expect(@instance.color).toEqual(jasmine.any(Color))
        expect(@instance.color.rgb).toEqual('1234')

    it 'intercepts dataForSave', ->
        @instance.color.rgb = 'mycolor'
        expect(@instance.color.dataForSave()).toEqual({rgb: 'mycolor'})

    it 'provides api_key', ->
        expect(@instance.color.api_path()).toEqual('test')

    it 'stores events and eventually sets them on model', ->
        spy1 = jasmine.createSpy()
        spy2 = jasmine.createSpy()

        @instance.color.on('change:rgb', spy1)
        @instance.color.once('change:rgb', spy2)
        expect(@instance.color.isProxy).toBe(true)
        @instance.color.rgb = 'newcolor'
        expect(@instance.color.isProxy).toBeUndefined()

        expect(spy1).toHaveBeenCalled()
        expect(spy2).toHaveBeenCalled()

    it 'fires proxyreplace event', ->
        spy = jasmine.createSpy('proxyreplace')
        @instance.color.on('proxyreplace', spy)
        expect(@instance.color.isProxy).toBe(true)
        @instance.color.rgb = 'foo'
        expect(spy).toHaveBeenCalled()
