#= require lanes/components/grid

COLLECTION_DATA = [
    {id:1, code:'TEST1', name: 'Nathan Stitt', notes: 'swell guy'}
    {id:2, code:'TEST2', name: 'Nathan Stitt', notes: 'Dupe of id #1'}
]

ROW_DATA = _.map COLLECTION_DATA, (r) -> _.values(r)

Model = Lanes.Test.defineModel(
    props: {id: 'integer', code: 'string', name: 'string', notes: 'string'}
)
LAST_ROW_SELECTOR = '.fixedDataTableRowLayout_rowWrapper:last-child .public_fixedDataTableCell_cellContent'

RenderEdit = (q, value) ->
    grid = LT.renderComponent(LC.Grid, props: {
        query: q, editor: true
    })
    _.dom(grid).qs(LAST_ROW_SELECTOR).click()
    editor = Lanes.Test.Utils.findRenderedComponentWithType(
        grid, Lanes.Components.Grid.RowEditor
    )
    _.dom(editor).qs('.field:nth-of-type(2) input').setValue(value)
    {grid, editor}

describe "Lanes.Components.Grid.RowEditor", ->

    beforeEach (done) ->
        Lanes.Test.syncSucceedWith(ROW_DATA)
        @query = new Lanes.Models.Query(
            fields: [ 'id', 'code', 'name', 'notes' ]
            src: Model
        )
        @collection = new Model.Collection(COLLECTION_DATA)
        @query.ensureLoaded().then(done)

    it 'sets the props', ->
        grid = LT.renderComponent(LC.Grid, props: {
            query: @query, editor: true
        })
        _.dom(grid).qs(LAST_ROW_SELECTOR).click()
        editor = Lanes.Test.Utils.findRenderedComponentWithType(grid, Lanes.Components.Grid.RowEditor)
        expect(editor.props.rowIndex).toEqual(1)
        expect(editor.props.model).toEqual(jasmine.any(Model))
        expect(editor.props.model.id).toEqual(2)

    it 'can edit both rows and collections', ->
        {editor} = RenderEdit(@query, 'BOB')
        _.dom(editor).qs('.btn.save').click()
        expect( @query.results.rowAt(1)[1] ).toEqual('BOB')

        @query.src = @collection
        {editor} = RenderEdit(@query, 'BOB')
        _.dom(editor).qs('.btn.save').click()
        expect(@collection.at(1).code).toEqual('BOB')

    it 'does not update when edit is canceled', ->
        {editor} = RenderEdit(@query, 'CANCKED')
        _.dom(editor).qs('.btn.cancel').click()
        expect( @query.results.rowAt(1)[1] ).toEqual('TEST2')
        @query.src = @collection
        {editor} = RenderEdit(@query, 'CANCELED')
        _.dom(editor).qs('.btn.cancel').click()

        expect( @collection.at(1).code ).toEqual('TEST2')
