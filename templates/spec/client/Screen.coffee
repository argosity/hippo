describe "<%= screen_class %>", ->

    it "can be rendered", ->
        screen = LT.renderComponent(<%= screen_class %>)
        expect(_.dom(screen).text).toMatch("Hello")
