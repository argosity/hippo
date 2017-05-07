#= require hippo/components/grid


DATA = {total:2, success:true, message:"Retrieve succeeded", data:[
    [1, "TEST1", "Nathan Stitt", "swell guy"]
    [2, "TEST2", "Nathan Stitt", "Dupe of id #1"]
]}

Model = Hippo.Test.defineModel(
    props: {id: 'integer', code: 'string', name: 'string', notes: 'string'}
)

LAST_ROW_SELECTOR = '.grid-body .r:last-child'
ADD_ROW_SELECTOR = 'button.add-row'

describe "Hippo.Components.Grid.PopoverEditor", ->

    beforeEach (done) ->
        LT.syncRespondWith(DATA)
        @query = new Hippo.Models.Query(
            src: Model, fields: [ 'id', 'code', 'name', 'notes' ]
        )
        @query.ensureLoaded().then =>
            @grid = LT.renderComponent(LC.Grid, props: {
                allowCreate: true, editor: Hippo.Components.Grid.PopoverEditor, query: @query
            })
            done()

    it "edits", (done) ->
        _.dom(@grid).qs(LAST_ROW_SELECTOR).click(clientX: 5)
        editor = Hippo.Test.Utils.findRenderedComponentWithType(
            @grid, Hippo.Components.Grid.PopoverEditor
        )
        _.dom(editor).qs('.field:nth-of-type(3) input').setValue('BOB')
        _.dom(editor).qs('.btn.save').click()
        expect( @query.results.rowAt(1)[2] ).toEqual('BOB')
        done()

    it 'adds row', (done) ->
        _.dom(@grid).qs(ADD_ROW_SELECTOR).click()
        editor = Hippo.Test.Utils.findRenderedComponentWithType(
            @grid, Hippo.Components.Grid.PopoverEditor
        )
        _.dom(editor).qs('.field:nth-of-type(3) input').setValue('BOB')
        _.dom(editor).qs('.btn.save').click()
        expect( @query.results.rowAt(0)[2] ).toEqual('BOB')
        done()
