Model = Hippo.Test.defineModel(
    props: {id: 'integer', code: 'string', name: 'string', notes: 'string'}
)

describe "Hippo.Components.NetworkActivityOverlay", ->

    it "doesn't render unless requesting", ->
        na = LT.renderComponent(LC.NetworkActivityOverlay, props:{message: 'Lookout 4 Bears'})
        expect(_.dom(na).el).toBe(null)

    it "renders message", ->
        na = LT.renderComponent(LC.NetworkActivityOverlay, props:{
            visible: true, message: 'Lookout 4 Bears'})
        expect(_.dom(na).qs('.message').text).toBe('Lookout 4 Bears')

    it 'chooses message based on request type', ->
        na = LT.renderComponent(LC.NetworkActivityOverlay, props:{visible:true})
        na.setState(isRequesting: 'GET')
        expect(_.dom(na).qs('.message').text).toBe('Loading…')
        na.setState(isRequesting: 'POST')
        expect(_.dom(na).qs('.message').text).toBe('Saving…')
        na.setState(isRequesting: 'DELETE')
        expect(_.dom(na).qs('.message').text).toBe('Deleting…')

    it 'briefly displays an error message', (done) ->
        model = new Model
        na = LT.renderComponent(LC.NetworkActivityOverlay, props:{
            errorTimeout: 2, model:model})
        na.setModelState(hasError: true)
        expect(_.dom(na).qs('.message').text).toBe('Error')
        _.delay( ->
            expect(_.dom(na).el).toBe(null)
            done()
        , 3)
