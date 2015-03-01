describe "AppyApp.Views.BigView", ->

    it "can be instantiated", ->
        view = new AppyApp.Views.BigView()
        expect(view).toEqual(jasmine.any(AppyApp.Views.BigView));
