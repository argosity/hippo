describe "Lanes.Models.AssociationMap", ->
    class Color
        constructor: -> super
        api_path: -> 'test'
        props: { id: 'integer', model_fk_id: 'integer', rgb: 'string' }
    Lanes.Models.Base.extend(Color)

    DATA = {total:1,success:true,message:"Retrieve succeeded",data:[
        [1,"TEST","Nathan Stitt",null,"0.0"]
    ]}
    RESPONSE = {
        status:200,
        contentType: "application/json"
        responseText: JSON.stringify(DATA)
    }
    beforeEach ->
        jasmine.Ajax.install()
    afterEach ->
        jasmine.Ajax.uninstall()

    it "sets up has_many associations", ->
        model = Lanes.Test.makeModel({
            associations:
                color:{ model: Color }
                colors: { collection: Color, fk: 'model_fk_id' }
            props: { id: 'integer', foo: 'string' }
        },{ id: 123 })
        color = model.colors.add({ rgb:'#ffffff' })
        expect(color).toEqual(jasmine.any(Color))
        expect(color.model_fk_id).toEqual(123)

        spy = jasmine.createSpy('sync')
        model.colors.sync = spy

        model.colors.fetch(force:true)

        expect(spy).toHaveBeenCalledWith('read', model.colors, jasmine.any(Object))
        call_options = spy.calls.mostRecent().args[2]
        expect(call_options.query).toEqual( model_fk_id: 123 )


    it "sets up belongs_to associations", ->
        model = Lanes.Test.makeModel({
            associations:
                color:{ model: Color }
            props: { id: 'integer', foo: 'string', color_id: 'integer' }
        },{ id: 123, color: { rgb: 'red' } })
        color = model.color
        expect(model.color).toEqual(jasmine.any(Color))

        expect(model.color.rgb).toEqual('red')
