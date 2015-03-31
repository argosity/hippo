describe "<%= view_class %>", ->

    it "can be instantiated", ->
        view = new <%= namespace %>.Views.<%= class_name %>()
        expect(view).toEqual(jasmine.any(<%= namespace %>.Views.<%= class_name %>));
