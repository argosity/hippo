#= require <%= namespace %>/screens/<%= name %>

describe "<%= class_name %> Screen Suite", ->

    it "can be instantiated", ->
        view = new <%= namespace.camelize %>.Screens.<%= class_name %>()
        expect(view).toEqual(jasmine.any(<%= namespace.camelize %>.Screens.<%= class_name %>));
