describe "Lanes.Model.User", ->

    it "saves callbacks across users", ->
        spy = jasmine.createSpy('callbackSpy')
        Lanes.current_user.on("change", spy)
        #expect( _.keys(Lanes.Models.UserEvents.CALLBACKS).length ).toEqual(2)

        testuser = Lanes.Test.makeModel({
            session:
                isLoggedIn: 'bool'
            canRead: -> true
        })
        Lanes.current_user = testuser

        Lanes.current_user.isLoggedIn = false

        expect(spy).toHaveBeenCalled()
