describe "Lanes.Screens.Definitions", ->
    orig_user = Lanes.current_user
    afterEach ->
        Lanes.current_user = orig_user
        delete Lanes.Test.DefinitionTestModel

    it "resets caches when user login status changes", ->

        testuser = Lanes.Test.makeModel({
            session:
                isLoggedIn: 'bool'
            canRead: -> true
        })
        Lanes.current_user = testuser
        Lanes.Test.DefinitionTestModel = Lanes.Test.defineModel({
            props: { id: 'integer', foo: 'string' }
        })
        expect(Lanes.current_user).not.toBe(null)
        Lanes.Screens.Definitions.groups.add( id: 'foo' )
        Lanes.Screens.Definitions.register(
            group_id: 'foo', model: 'Lanes.Test.DefinitionTestModel', id: 'screen'
        )
        group = Lanes.Screens.Definitions.groups.first()
        expect(group).not.toBe(null)

        expect(Lanes.Screens.Definitions.groups.available().length).toEqual(1)
        expect( group.screens().length ).toEqual(1)

        Lanes.current_user.canRead = -> false
        Lanes.current_user.isLoggedIn = false

        expect( group.screens().length ).toEqual(0)
        expect( Lanes.Screens.Definitions.groups.available().length ).toEqual(0)
