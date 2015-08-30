#= require lanes/components/grid


DATA = {total:2, success:true, message:"Retrieve succeeded", data:[
    [1, "TEST1", "Nathan Stitt", "swell guy"]
    [2, "TEST2", "Nathan Stitt", "Dupe of id #1"]
]}

Model = Lanes.Test.defineModel(
    props: {id: 'integer', code: 'string', name: 'string', notes: 'string'}
)

describe "Lanes.Components.Grid", ->

    beforeEach (done) ->
        LT.syncRespondWith(DATA)
        @query = new Lanes.Models.Query(
            src: Model, fields: [ 'id', 'code', 'name', 'notes' ]
        )
        @collection = new Model.Collection
        @query.ensureLoaded().then => @collection.ensureLoaded().then -> done()

    it "loads from a result set", (done) ->
        renderGrid = (q) ->
            loaded = spyOn(q.results, 'ensureLoaded').and.callThrough()
            grid = LT.renderComponent(LC.Grid, props: query: q)
            _.defer (done)
            expect(loaded).toHaveBeenCalled()
            expect(_.dom(grid).qsa('.fixedDataTableRowLayout_rowWrapper').length)
                .toEqual( q.results.length + 1 )
        renderGrid(@query)
        @query.src = @collection
        renderGrid(@query)

    it 'can be edited', ->
        spy = jasmine.createSpy('selection')
        grid = LT.renderComponent(LC.Grid, props: {
            query: @query, editor: true, onSelectionChange: spy
        })
        expect(_.dom(grid).qsa('.fixedDataTableRowLayout_rowWrapper').length).toEqual(3)
        _.dom(grid).qs('.fixedDataTableRowLayout_rowWrapper:last-child .public_fixedDataTableCell_cellContent').click()
        expect(spy).toHaveBeenCalled()
