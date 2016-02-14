#= require lanes/components/grid


DATA = {total:2, success:true, message:"Retrieve succeeded", data:[
    [1, "TEST1", "Nathan Stitt", "swell guy"]
    [2, "TEST2", "Nathan Stitt", "Dupe of id #1"]
]}

Model = Lanes.Test.defineModel(
    props: {id: 'integer', code: 'string', name: 'string', notes: 'string'}
)

renderGrid = (q, done) ->
    loaded = spyOn(q.results, 'ensureLoaded').and.callThrough()
    grid = LT.renderComponent(LC.Grid, props: query: q)
    expect(loaded).toHaveBeenCalled()
    _.defer ->
        expect(_.dom(grid).qsa('.r').length)
            .toEqual( q.results.length )
        done()

describe "Lanes.Components.Grid", ->

    beforeEach (done) ->
        LT.syncRespondWith(DATA)
        @query = new Lanes.Models.Query(
            src: Model, fields: [ 'id', 'code', 'name', 'notes' ]
        )
        @collection = new Model.Collection
        @query.ensureLoaded().then => @collection.ensureLoaded().then -> done()

    describe "loading", ->

        it "from a result set", (d) ->
            renderGrid(@query, d)

        it "from a collection", (d) ->
            @query.src = @collection
            renderGrid(@query, d)

    it 'renders toolbar', ->
        grid = LT.renderComponent(LC.Grid, props: {
            query: @query, editor: true, allowCreate: true
        })
        tb = _.dom(grid).qs('.toolbar')
        expect(tb).not.toBeUndefined()

    it 'notifies when selection changes', (done) ->
        spy = jasmine.createSpy('selection')
        grid = LT.renderComponent(LC.Grid, props: {
            query: @query, editor: true, onSelectionChange: spy
        })
        _.defer ->
            _.dom(grid).qs('.grid-body .c').click()
            expect(spy).toHaveBeenCalled()
            done()
