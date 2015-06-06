describe "AppyApp.Components.Big", ->

    it "can be rendered", ->
        element = LT.renderComponent(AppyApp.Components.Big)
        expect(_.dom(element).text).toMatch("Big")
