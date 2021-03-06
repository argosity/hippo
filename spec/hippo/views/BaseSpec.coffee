# describe "Hippo.Views.Base", ->

#     it "fires el change on render", ->
#         spy = jasmine.createSpy()
#         view = Hippo.Test.makeView({
#             template: "<p>hi</p"
#         })
#         view.on("change:el", spy)
#         view.render()
#         expect(spy).toHaveBeenCalled()

#     it "renders a template file", ->
#         spy = jasmine.createSpy('view-test').and.callFake ->
#             "<p>a test</p>"
#         Hippo.Templates['/view-test'] = spy

#         view = Hippo.Test.makeView({
#             templatePrefix: ''
#             templateName: "view-test"
#         }, { model: new Hippo.Test.DummyModel({name: 'foo'}) } )
#         view.render()
#         expect(spy).toHaveBeenCalledWith( model: { name: 'foo' }, collection: undefined )
#         expect(view.el.innerHTML).toEqual("a test")

#     it "renders a template string", ->
#         view = Hippo.Test.makeView({
#             template: "<p>hello test</p"
#         })
#         expect(view.template).toEqual "<p>hello test</p"
#         view.render()
#         expect(view.el.tagName).toEqual("P")
#         expect(view.el.innerHTML).toEqual("hello test")

#     it "listens to domEvents", ->
#         spy = jasmine.createSpy('onClick')
#         el = _.el( 'div',{id: 'testdiv'} )
#         view = Hippo.Test.makeView({
#             domEvents: { "click #mylink": 'onClick' }
#             template: "<div>text,text,text<a id='mylink'>click me</a>mor text</div>"
#             onClick: spy
#         },{el: el})
#         expect(view.domEvents["click #mylink"]).toEqual('onClick')
#         view.render()
#         view.$('a').trigger('click',22)
#         expect(spy).toHaveBeenCalledWith(jasmine.any(Object),22)

#     it "updates from bindings", ->
#         model = new Hippo.Test.DummyModel({ name: "Bob" })
#         view = Hippo.Test.makeView({
#             bindings: {
#                 "model.name": { hook: 'link' }
#                 "model.url":  { type:'attribute', name: 'href', hook: 'link' }
#             }
#             template: "<div>text,text,text<a data-hook='link'>click me</a>mor text</div>"
#         }, { model: model })
#         view.render()
#         expect( view.$('a').text() ).toEqual("Bob")
#         model.name="Ralph"
#         model.url = 'http://hippoframework.org/'
#         expect( view.$('a').text() ).toEqual("Ralph")
#         expect( view.$('a').attr('href') ).toEqual( model.url )

#     it "renders subviews", ->
#         class LowerView
#             template: "<h1>Hello from Lower View</h1>"
#             constructor: -> super
#             session: { answer: 'string' }
#         Hippo.Views.Base.extend(LowerView)
#         model = new Hippo.Test.DummyModel
#         view = Hippo.Test.makeView({
#             subviews:
#                 lower:
#                     hook: 'lower'
#                     waitFor: 'model.name'
#                     view: LowerView
#             template: "<div>text,text,text<div data-hook='lower'>unmodified</div>More text</div>"
#             subviewOptions: ->{ answer: '42' }
#         }, { model: model })
#         view.render()
#         expect(view.$('[data-hook]').text()).toEqual("unmodified")
#         expect( view.$el.text() ).not.toMatch(/Hello from Lower View/)
#         model.name="Ralph"
#         expect( view.$el.text() ).toMatch(/Hello from Lower View/)
#         expect(view.lower.answer).toEqual('42')

#     it "renders collection views", ->
#         class LowerView
#             template: "<h1>Hello from Lower View</h1>"
#             constructor: -> super
#             bindings: { "model.name": { type: "text" } }
#         Hippo.Views.Base.extend(LowerView)
#         collection = new Hippo.Test.DummyModel.Collection
#         view = Hippo.Test.makeView({
#             subviews:
#                 lower:
#                     hook: 'lower'
#                     collection: 'collection'
#                     view: LowerView
#             template: "<div>text,text,text<div data-hook='lower'>unmodified</div>More text</div>"
#         }, { collection: collection})
#         view.render()
#         expect(view.$('h1').length).toEqual(0)
#         collection.add([{ name: "One"}, {name: "Two"},{name:"Three"}])
#         expect(view.$('h1').length).toEqual(3)
#         expect(view.$('h1:first').text()).toMatch('One')

#     it "caches elements in ui", ->
#         spy = jasmine.createSpy('onClick')
#         view = Hippo.Test.makeView({
#             ui:
#                 link: '#linky'
#             domEvents:
#                 'click @ui.link': spy
#             template: "<div>text,text,text<a id='linky'>unmodified</a>More text</div>"
#         })
#         view.render()
#         expect(view.ui.link.length).toEqual(1)
#         view.$('a').click()
#         expect(spy).toHaveBeenCalled()


#     it "invokes model events", ->
#         nameSpy = jasmine.createSpy()
#         urlSpy  = jasmine.createSpy()
#         model   = new Hippo.Test.DummyModel
#         view = Hippo.Test.makeView({
#             modelEvents:
#                 'change:name': nameSpy
#                 'change:url' : 'onURLChange'
#             onURLChange: urlSpy
#         },{ model: model })

#         model.name="Ralph"
#         expect(nameSpy).toHaveBeenCalled()


#     it "invokes collection events", ->
#         eventSpy = jasmine.createSpy('event')
#         view = Hippo.Test.makeView({
#             collectionEvents:
#                 all: 'onEvent'
#             onEvent: eventSpy
#             initialize: -> this.collection = new Hippo.Test.DummyModel.Collection
#         })
#         expect(eventSpy).not.toHaveBeenCalled()
#         view.collection.add(new Hippo.Test.DummyModel)
#         expect(eventSpy).toHaveBeenCalled()
