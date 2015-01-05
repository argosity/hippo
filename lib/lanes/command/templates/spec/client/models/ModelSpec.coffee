describe "<%= namespace.camelize %>.Models.<%= class_name %>", ->

    it "can be instantiated", ->
        model = new <%= namespace.camelize %>.Models.<%= class_name %>()
        expect(model).toEqual(jasmine.any(<%= namespace.camelize %>.Models.<%= class_name %>))
