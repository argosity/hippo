describe "AppyApp.Screens.ReadySetGo", ->

    it "can be rendered", ->
        screen = LT.renderComponent(AppyApp.Screens.ReadySetGo)
        expect(_.dom(screen).text).toBeTruthy()
