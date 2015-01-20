#= require <%= namespace %>/screens/<%= name %>

describe "<%= namespace.camelize %>.Screens.<%= class_name %>", ->

    it "can be instantiated", ->
        view = new <%= namespace.camelize %>.Screens.<%= class_name %>()
        expect(view).toEqual(jasmine.any(<%= namespace.camelize %>.Screens.<%= class_name %>));
