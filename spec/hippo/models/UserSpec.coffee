describe "Hippo.Model.User", ->

    it "saves callbacks across users", ->
        spy = jasmine.createSpy('callbackSpy')
        Hippo.current_user.on("change", spy)
        #expect( _.keys(Hippo.Models.UserEvents.CALLBACKS).length ).toEqual(2)

        testuser = Hippo.Test.makeModel({
            session:
                isLoggedIn: 'bool'
            canRead: -> true
        })
        Hippo.current_user = testuser

        Hippo.current_user.isLoggedIn = false

        expect(spy).toHaveBeenCalled()
