describe "Lanes.Components.NetworkActivityOverlay", ->

    it "doesn't render unless requesting", ->
        na = LT.renderComponent(LC.NetworkActivityOverlay, props:{message: 'Lookout 4 Bears'})
        expect(_.dom(na).el).toBe(null)


    it "renders message", ->
        na = LT.renderComponent(LC.NetworkActivityOverlay, props:{
            isRequesting: true, message: 'Lookout 4 Bears'})
        expect(_.dom(na).qs('.message').text).toBe('Lookout 4 Bears')

    it 'chooses message based on request type', ->
        na = LT.renderComponent(LC.NetworkActivityOverlay, props:{isRequesting: 'patch'})
        expect(_.dom(na).qs('.message').text).toBe('Saving…')
        na = LT.renderComponent(LC.NetworkActivityOverlay, props:{isRequesting: 'get'})
        expect(_.dom(na).qs('.message').text).toBe('Loading…')

    it 'briefly displays an error message', (done) ->
        na = LT.renderComponent(LC.NetworkActivityOverlay, props:{hasError: true, errorTimeout: 2})
        expect(_.dom(na).qs('.message').text).toBe('Error')
        _.delay( ->
            expect(_.dom(na).el).toBe(null)
            done()
        , 3)
