describe "<%= namespace.camelize %>.Views.<%= class_name %>", ->

    it "can be instantiated", ->
        view = new <%= namespace.camelize %>.Views.<%= class_name %>()
        expect(view).toEqual(jasmine.any(<%= namespace.camelize %>.Views.<%= class_name %>));
