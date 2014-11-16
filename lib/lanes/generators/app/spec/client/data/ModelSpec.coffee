describe "Choices Input Suite", ->

    it "can be instantiated", ->
        model = new Lanes.<%= namespace.camelize %>.<%= class_name %>()
        expect(model).toEqual(jasmine.any(Lanes.<%= namespace.camelize %>.<%= class_name %>));
