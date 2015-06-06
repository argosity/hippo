describe "<%= component_class %>", ->

    it "can be rendered", ->
        element = LT.renderComponent(<%= component_class %>)
        expect(_.dom(element).text).toMatch("<%= class_name %>")
