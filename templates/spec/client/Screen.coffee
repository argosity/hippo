describe "<%= screen_class %>", ->

    it "can be rendered", ->
        screen = LT.renderComponent(<%= screen_class %>)
        expect(screen.getDOMNode().textContent).toMatch("Hello")
