describe "<%= class_name %> View Suite", ->

    it "can be instantiated", ->
        view = new Lanes.<%= namespace.camelize %>.Views.<%= class_name %>()
        expect(view).toEqual(jasmine.any(Lanes.<%= namespace.camelize %>.Views.<%= class_name %>));
