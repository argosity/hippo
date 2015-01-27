describe "<%= namespace %>.Models.<%= class_name %>", ->

    it "can be instantiated", ->
        model = new <%= namespace %>.Models.<%= class_name %>()
        expect(model).toEqual(jasmine.any(<%= namespace %>.Models.<%= class_name %>))
