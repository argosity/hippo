
class Model extends Lanes.Data.Model
    props:
        id: 'number',
        name: ['string', true],
        html: 'string',
        url: 'string',
        something: 'string',
        fireDanger: 'string'

    session:
        active: 'boolean'

    derived:
        classes:
            deps: ['something', 'fireDanger', 'active'],
            fn: -> this.something + this.active;

class Collection extends Lanes.Data.Collection
    model: Model

describe "BaseView Suite", ->
    View = undefined
    makeView = (props,args={})->
        _.extend(View.prototype, props)
        Lanes.Views.Base.extend(View)
        return new View(args)

    beforeEach ->
        class TestView
            constructor: -> super
        View = TestView

    it "fires el change on render", ->
        spy = jasmine.createSpy()
        view = makeView({
            template: "<p>hi</p"
        })
        view.on("change:el", spy)
        view.render()
        expect(spy).toHaveBeenCalled()


    it "renders a template string", ->
        view = makeView({
            template: "<p>hi</p"
        })
        expect(view.template).toEqual "<p>hi</p"
        view.render()
        expect(view.el.tagName).toEqual("P")
        expect(view.el.innerHTML).toEqual("hi")

    it "listens to events", ->
        spy = jasmine.createSpy('onClick')
        el = _.el( 'div',{id: 'testdiv'} )
        view = makeView({
            events: { "click #mylink": 'onClick' }
            template: "<div>text,text,text<a id='mylink'>click me</a>mor text</div>"
            onClick: spy
        },{el: el})
        expect(view.events["click #mylink"]).toEqual('onClick')
        view.render()
        view.$('a').trigger('click',22)
        expect(spy).toHaveBeenCalledWith(jasmine.any(Object),22)

    it "updates from bindings", ->
        model = new Model({ name: "Bob" })
        view = makeView({
            bindings: {
                "model.name": { hook: 'link' }
                "model.url":  { type:'attribute', name: 'href', hook: 'link' }
            }
            template: "<div>text,text,text<a data-hook='link'>click me</a>mor text</div>"
        }, { model: model })
        view.render()
        expect( view.el ).toContainText("Bob")
        model.name="Ralph"
        model.url = 'http://lanesframework.org/'
        expect( view.$('a').text() ).toEqual("Ralph")
        expect( view.$('a') ).toHaveAttr('href', model.url )

    it "renders subviews", ->
        class LowerView
            template: "<h1>Hello from Lower View</h1>"
            constructor: -> super
            session: { answer: 'string' }
        Lanes.Views.Base.extend(LowerView)
        model = new Model
        view = makeView({
            subviews:
                lower:
                    hook: 'lower'
                    waitFor: 'model.name'
                    view: LowerView
            template: "<div>text,text,text<div data-hook='lower'>unmodified</div>More text</div>"
            subviewOptions: ->{ answer: '42' }
        }, { model: model })
        view.render()
        expect(view.el).toContainText("unmodified")
        expect(view.el).not.toContainText("Lower View")
        model.name="Ralph"
        expect(view.el).toContainText("Lower View")
        expect(view.lower.answer).toEqual('42')

    it "renders collection views", ->
        class LowerView
            template: "<h1>Hello from Lower View</h1>"
            constructor: -> super
            bindings: { "model.name": { type: "text" } }
        Lanes.Views.Base.extend(LowerView)
        collection = new Collection
        view = makeView({
            subviews:
                lower:
                    hook: 'lower'
                    collection: 'collection'
                    view: LowerView
            template: "<div>text,text,text<div data-hook='lower'>unmodified</div>More text</div>"
        }, { collection: collection})
        view.render()
        expect(view.$('h1')).toHaveLength(0)
        collection.add([{ name: "One"}, {name: "Two"},{name:"Three"}])
        expect(view.$('h1')).toHaveLength(3)
        expect(view.$('h1:first')).toContainText('One')

    it "caches elements in ui", ->
        spy = jasmine.createSpy('onClick')
        view = makeView({
            ui:
                link: '#linky'
            events:
                'click @ui.link': spy
            template: "<div>text,text,text<a id='linky'>unmodified</a>More text</div>"
        })
        view.render()
        expect(view.ui.link).toHaveLength(1)
        view.$('a').click()
        expect(spy).toHaveBeenCalled()


    it "invokes model events", ->
        nameSpy = jasmine.createSpy()
        urlSpy  = jasmine.createSpy()
        model   = new Model
        view = makeView({
            modelEvents:
                'change:name': nameSpy
                'change:url' : 'onURLChange'
            onURLChange: urlSpy
        },{ model: model })

        model.name="Ralph"
        expect(nameSpy).toHaveBeenCalled()


    it "invokes collection events", ->
        eventSpy = jasmine.createSpy('event')
        view = makeView({
            collectionEvents:
                all: 'onEvent'
            onEvent: eventSpy
            initialize: -> this.collection = new Collection
        })
        expect(eventSpy).not.toHaveBeenCalled()
        view.collection.add(new Model)
        expect(eventSpy).toHaveBeenCalled()
