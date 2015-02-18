describe "AppyApp.Screens.Base", ->

    it "can be instantiated", ->
        view = new AppyApp.Screens.Base()
        expect(view).toEqual(jasmine.any(AppyApp.Screens.Base));
