describe "<%= class_name %> Model Suite", ->

    it "can be instantiated", ->
        model = new Lanes.<%= namespace.camelize %>.Data.<%= class_name %>()
        expect(model).toEqual(jasmine.any(Lanes.<%= namespace.camelize %>.Data.<%= class_name %>));
