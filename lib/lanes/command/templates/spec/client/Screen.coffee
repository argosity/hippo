describe "<%= class_name %> Screen Suite", ->

    it "can be instantiated", ->
        view = new <%= namespace.camelize %>.Views.<%= class_name %>()
        expect(view).toEqual(jasmine.any(Lanes.<%= namespace.camelize %>.Views.<%= class_name %>));
