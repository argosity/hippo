# describe "Lanes.Views.FormBindings", ->

#     it "updates inputs", ->
#         model = new Lanes.Test.DummyModel({name: 'start'})
#         view  = Lanes.Test.makeView({
#             template: '<div><h1>foo</h1><input type="text" name="name"></div>'
#         }, { formBindings: true, model: model })
#         view.render()
#         input = view.$('input')
#         expect(input.val()).toEqual('start')
#         input.val('test')
#         input.trigger('change')
#         expect(model.name).toEqual('test')

#     it "updates radio fields", ->
#         model = new Lanes.Test.DummyModel({name: 'start'})
#         view  = Lanes.Test.makeView({
#             template: """
#                 <div>
#                     <input id="a" type="radio" name="name" value="one">One
#                     <input id="b" type="radio" name="name" value="two">Two
#                     <input id="c" type="radio" name="name" value="three">Three
#                 </div>
#                 """
#         }, { formBindings: true, model: model })
#         view.render()
#             .$("#b")
#             .attr('checked', true)
#             .trigger('change')
#         expect(model.name).toEqual('two')
#         model.name="three"
#         expect(view.$("input:checked").attr("id")).toEqual('c')
