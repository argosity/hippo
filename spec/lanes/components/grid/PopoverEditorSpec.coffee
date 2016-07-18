#= require lanes/components/grid


DATA = {total:2, success:true, message:"Retrieve succeeded", data:[
    [1, "TEST1", "Nathan Stitt", "swell guy"]
    [2, "TEST2", "Nathan Stitt", "Dupe of id #1"]
]}

Model = Lanes.Test.defineModel(
    props: {id: 'integer', code: 'string', name: 'string', notes: 'string'}
)

LAST_ROW_SELECTOR = '.grid-body .r:last-child'
ADD_ROW_SELECTOR = 'button.add-row'

describe "Lanes.Components.Grid.PopoverEditor", ->

    beforeEach (done) ->
        LT.syncRespondWith(DATA)
        @query = new Lanes.Models.Query(
            src: Model, fields: [ 'id', 'code', 'name', 'notes' ]
        )
        @query.ensureLoaded().then =>
            @grid = LT.renderComponent(LC.Grid, props: {
                allowCreate: true, editor: Lanes.Components.Grid.PopoverEditor, query: @query
            })
            done()

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
