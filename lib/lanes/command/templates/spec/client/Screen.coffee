describe "<%= namespace %>.Screens.<%= class_name %>", ->

    it "can be instantiated", ->
        view = new <%= namespace %>.Screens.<%= class_name %>()
        expect(view).toEqual(jasmine.any(<%= namespace %>.Screens.<%= class_name %>));
