#= require lanes/components/select-field

Brand = Lanes.Test.defineModel(
    props: {id: 'integer', code: 'string', name: 'string'}
)

BRAND_DATA = {total:3, success:true, message:"Retrieve succeeded", data:[
    {id: 1, code: "GM",    name: "General Motors"}
    {id: 2, code: "FORD",  name: "Ford Motor Co."}
    {id: 3, code: "DODGE", name: "Chrysler/Dodge"}
]}

VALUE_CLASS = '.form-control-static'

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
        sf = LT.renderComponent(LC.SelectField,
             props:{model: @car, name: 'brand', labelField: 'name'})
        expect(_.dom(sf).qs(VALUE_CLASS).text).toBe('')
        @car.set(brand: @brands.at(0))
        _.defer ->
            expect(_.dom(sf).qs(VALUE_CLASS).text).toBe('General Motors')
            done()

    it "renders as edit", ->
        @car.set(brand: @brands.at(1))
        sf = LT.renderComponent(LC.SelectField, props:{
             model: @car, name: 'brand', labelField: 'name',
             editOnly: true, collection: @brands })
        expect(_.dom(sf).qs('input[type=text]').value).toEqual('Ford Motor Co.')

    it 'uses a custom data source', (done) ->
        sf = LT.renderComponent(LC.SelectField, props:{
            model: @car, name: 'brand', editOnly: true
            value: 4, choices: [{ label: 'Toyota', id: 4 }]
        })
        _.defer ->
            expect(_.dom(sf).qs('input[type=text]').value).toEqual('Toyota')
            done()

    it 'sets value when changed', ->
        @car.set(brand: @brands.at(1))
        sf = LT.renderComponent(LC.SelectField, props:{
            model: @car, name: 'brand', labelField: 'name',
            fetchOnSelect: false, editOnly: true, choices: @brands.models
        })
        _.dom(sf).qs('.rw-select').click()
        _.dom(sf).qs('.rw-list li:last-child').click()
        expect(@car.brand.code).toEqual('DODGE')

    it 'can select multiple values', (done) ->
        sf = LT.renderComponent(LC.SelectField, props:{
            queryModel: Car,
            multiSelect: true, model: @car, name: 'carTypes', fetchOnSelect: false
            labelField: 'name', editOnly: true, choices: @brands.models
        })

        _.dom(sf).qs('.rw-input').focus()
        _.defer =>
            expect( _.dom(sf).qsa('.rw-list li').length ).toEqual(@brands.length)
            _.dom(sf).qs('.rw-list-option:nth-child(1)').click()
            _.dom(sf).qs('.rw-input').focus()
            _.dom(sf).qs('.rw-list-option:nth-child(2)').click()
            expect(_.map(@car.carTypes, 'id')).toEqual([1, 3])
            done()

    it 'renders label for single values', ->
        @car.set(brand: @brands.last())
        sf = LT.renderComponent(LC.SelectField, props:{
            model: @car, name: 'brand', labelField: 'name',
            choices: @brands.models
        })
        expect(_.dom(sf).qs(VALUE_CLASS).text).toEqual('Chrysler/Dodge')

    it 'renders label for multiple values', ->
        @car.carTypes = [ @brands.at(0), @brands.at(2) ]
        sf = LT.renderComponent(LC.SelectField, props:{
            queryModel: Car, multiSelect: true, model: @car, name: 'carTypes'
            labelField: 'name', choices: @brands.models
        })
        expect(_.dom(sf).qs(VALUE_CLASS).text).toEqual('General Motors and Chrysler/Dodge')


    it "renders all choices", ->
        sf = LT.renderComponent(LC.SelectField, props:{
            queryModel: Car, model: @car, name: 'brand', labelField: 'name',
            editOnly: true, choices: @brands.models
        })
        _.dom(sf).qs('.rw-select').click()
        labels = _.map _.dom(sf).qsa('li.rw-list-option'), 'textContent'
        expect(labels).toEqual(["General Motors", "Ford Motor Co.", "Chrysler/Dodge"])
