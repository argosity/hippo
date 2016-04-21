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

describe "Lanes.Components.Grid.PopoverEditor", ->

    beforeEach (done) ->
        @query = new Lanes.Models.Query(
            fields: [ 'id', 'code', 'name', 'notes' ], src: Model
        )
        Lanes.Test.syncSucceedWith(ROW_DATA)
        @query.ensureLoaded().then(done)
        @grid = LT.renderComponent(LC.Grid, props: {
            editor: Lanes.Components.Grid.PopoverEditor
            query: @query, allowCreate: true
        })

    it "edits", (done) ->
        _.dom(@grid).qs(LAST_ROW_SELECTOR).click(clientX: 5)
        editor = Lanes.Test.Utils.findRenderedComponentWithType(
            @grid, Lanes.Components.Grid.PopoverEditor
        )
        _.dom(editor).qs('.field:nth-of-type(3) input').setValue('BOB')
        _.dom(editor).qs('.btn.save').click()
        expect( @query.results.rowAt(1)[2] ).toEqual('BOB')
        done()

    it 'adds row', (done) ->
        _.dom(@grid).qs(ADD_ROW_SELECTOR).click()
        editor = Lanes.Test.Utils.findRenderedComponentWithType(
            @grid, Lanes.Components.Grid.PopoverEditor
        )
        _.dom(editor).qs('.field:nth-of-type(3) input').setValue('BOB')
        _.dom(editor).qs('.btn.save').click()
        expect( @query.results.rowAt(0)[2] ).toEqual('BOB')
        done()
