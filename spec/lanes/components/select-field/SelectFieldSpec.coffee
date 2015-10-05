#= require lanes/components/select-field

Brand = Lanes.Test.defineModel(
    props: {id: 'integer', code: 'string', name: 'string'}
)

BRAND_DATA = {total:3, success:true, message:"Retrieve succeeded", data:[
    {id: 1, code: "GM",    name: "General Motors"}
    {id: 2, code: "FORD",  name: "Ford Motor Co."}
    {id: 3, code: "DODGE", name: "Chrysler/Dodge"}
]}

Car = Lanes.Test.defineModel(
    props: {id: 'integer', code: 'string', brand_id: 'integer'}
    session:
        carTypes: 'array'

    associations:
        brand: {model: Brand}
)

describe "Lanes.Components.SelectField", ->
    beforeEach (done) ->
        @car = new Car
        LT.syncRespondWith(BRAND_DATA)
        @brands = new Brand.Collection
        @brands.ensureLoaded().then(done)

    it "renders read only", (done) ->
        sf = LT.renderComponent(LC.SelectField, props:{model: @car, name: 'brand', labelField: 'name'})
        expect(_.dom(sf).qs('.display').text).toBe('')
        @car.set(brand: @brands.at(0))
        _.defer ->
            expect(_.dom(sf).qs('.display').text).toBe('General Motors')
            done()


    it "renders as edit", ->
        @car.set(brand: @brands.at(1))
        sf = LT.renderComponent(LC.SelectField, props:{
            model: @car, name: 'brand', labelField: 'name', editOnly: true, collection: @brands
        })
        expect(_.dom(sf).qs('input[type=text]').value).toEqual('Ford Motor Co.')

    it 'uses a custom data source', ->
        sf = LT.renderComponent(LC.SelectField, props:{
            model: @car, name: 'brand', editOnly: true
            getSelection: -> { label: 'Toyota', id: 4 }
        })
        expect(_.dom(sf).qs('input[type=text]').value).toEqual('Toyota')

    it 'sets value when changed', ->
        @car.set(brand: @brands.at(1))
        sf = LT.renderComponent(LC.SelectField, props:{
            model: @car, name: 'brand', labelField: 'name', editOnly: true, collection: @brands
        })
        _.dom(sf).qs('.rw-select').click()
        _.dom(sf).qs('li.rw-list-option:last-child').click()
        expect(@car.brand.code).toEqual('DODGE')

    it 'can select multiple values', ->
        sf = LT.renderComponent(LC.SelectField, props:{
            multi: true, model: @car, name: 'carTypes',
            labelField: 'name', editOnly: true, collection: @brands
        })
        spyOn(@brands, 'fetch').and.callThrough()
        _.dom(sf).qs('.rw-input').focus()
        expect(@brands.fetch).toHaveBeenCalled()

        expect( _.dom(sf).qsa('.rw-list-option').length ).toEqual(@brands.length)
        _.dom(sf).qs('.rw-list-option:nth-child(1)').click()
        _.dom(sf).qs('.rw-input').focus()
        _.dom(sf).qs('.rw-list-option:nth-child(3)').click()
        expect(_.pluck(@car.carTypes, 'id')).toEqual([1, 3])

    it 'renders label for multiple values', ->
        @car.carTypes = [ @brands.at(0), @brands.at(2) ]
        sf = LT.renderComponent(LC.SelectField, props:{
            multi: true, model: @car, name: 'carTypes',
            labelField: 'name', collection: @brands
        })
        expect(_.dom(sf).qs('.display').text).toEqual('General Motors and Chrysler/Dodge')
