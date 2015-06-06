describe "AppyApp.Screens.ReadySetGo", ->

    it "can be rendered", ->
        screen = LT.renderComponent(AppyApp.Screens.ReadySetGo)
        expect(screen.getDOMNode().textContent).toMatch("Hello")
