describe "<%= class_name %> Model Suite", ->

    it "can be instantiated", ->
        model = new <%= namespace.camelize %>.Models.<%= class_name %>()
        expect(model).toEqual(jasmine.any(<%= namespace.camelize %>.Models.<%= class_name %>))
