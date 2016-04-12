#= require lanes/components/grid

COLLECTION_DATA = [
    {id:1, code:'TEST1', name: 'Nathan Stitt', notes: 'swell guy'}
    {id:2, code:'TEST2', name: 'Nathan Stitt', notes: 'Dupe of id #1'}
]

ROW_DATA = _.map COLLECTION_DATA, (r) -> _.values(r)

Model = Lanes.Test.defineModel(
    props: {id: 'integer', code: 'string', name: 'string', notes: 'string'}
)

LAST_ROW_SELECTOR = '.grid-body .r:last-child'
ADD_ROW_SELECTOR = 'button.add-row'

RenderGrid = (q) ->
    LT.renderComponent(LC.Grid, props: {
        query: q, editor: true, allowCreate: true
    })

RenderEdit = (q, value) ->
    Lanes.Test.syncSucceedWith(ROW_DATA)
    grid = RenderGrid(q)

    new _.Promise (res, rej) -> _.defer ->
        _.dom(grid).qs(LAST_ROW_SELECTOR).click()
        editor = Lanes.Test.Utils.findRenderedComponentWithType(
            grid, Lanes.Components.Grid.RowEditor
        )
        _.dom(editor).qs('.field:nth-of-type(2) input').change(target: {value})
        res({grid, editor})



CommonSpecs = ->

    it 'sets the props', (done) ->
        grid = LT.renderComponent(LC.Grid, props: {
            query: @query, editor: true
        })
        _.defer ->
            _.dom(grid).qs(LAST_ROW_SELECTOR).click()
            editor = Lanes.Test.Utils.findRenderedComponentWithType(grid, LC.Grid.RowEditor)
            expect(editor.props.rowIndex).toEqual(1)
            expect(editor.props.model).toEqual(jasmine.any(Model))
            expect(editor.props.model.id).toEqual(2)
            done()

    it 'can edit', (done) ->
        RenderEdit(@query, 'BOB').then ({editor}) =>
            _.dom(editor).qs('.btn.save').click()
            expect( @query.results.rowAt(1)[1] ).toEqual('BOB')
            done()

    it 'does not update when edit is canceled', (done) ->
        expect( @query.results.rowAt(1)[1] ).toEqual('TEST2')
        RenderEdit(@query, 'CANCKED').then ({editor}) =>
            _.dom(editor).qs('.btn.cancel').click()
            expect( @query.results.rowAt(1)[1] ).toEqual('TEST2')
            done()

    it 'removes an unsaved row when editing is canceled', (done) ->
        grid = RenderGrid(@query)
        _.defer =>
            addRow = spyOn(@query.results, 'addBlankRow').and.callThrough()
            removeRow = spyOn(@query.results, 'removeRow').and.callThrough()
            expect(@query.results.length).toEqual(2)
            _.dom(grid).qs(ADD_ROW_SELECTOR).click()
            expect(@query.results.addBlankRow).toHaveBeenCalled()
            editor = Lanes.Test.Utils.findRenderedComponentWithType(
                grid, Lanes.Components.Grid.RowEditor
            )
            expect(@query.results.length).toEqual(3)
            _.dom(editor).qs('.btn.cancel').click()
            expect(@query.results.removeRow).toHaveBeenCalled()
            expect(@query.results.length).toEqual(2)
            done()

describe "Lanes.Components.Grid.RowEditor", ->

    describe "using row based result set", ->
        beforeEach (done) ->
            @query = new Lanes.Models.Query(
                fields: [ 'id', 'code', 'name', 'notes' ], src: Model
            )
            Lanes.Test.syncSucceedWith(ROW_DATA)
            @query.ensureLoaded().then(done)
        CommonSpecs()


    describe "using a collection", ->
        beforeEach ->
            @query = new Lanes.Models.Query(
                fields: [ 'id', 'code', 'name', 'notes' ],
                src: new Model.Collection(COLLECTION_DATA)
            )
        CommonSpecs()
