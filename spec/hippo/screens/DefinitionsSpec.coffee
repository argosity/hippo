describe "Hippo.Screens.Definitions", ->
    orig_user = Hippo.current_user
    afterEach ->
        Hippo.current_user = orig_user
        delete Hippo.Test.DefinitionTestModel

    it "resets caches when user login status changes", ->

        testuser = Hippo.Test.makeModel({
            session:
                isLoggedIn: 'bool'
            hasAccess: -> true
        })
        Hippo.current_user = testuser
        Hippo.Test.DefinitionTestModel = Hippo.Test.defineModel({
            props: { id: 'integer', foo: 'string' }
        })
        expect(Hippo.current_user).not.toBe(null)
        Hippo.Screens.Definitions.groups.add( id: 'foo' )
        Hippo.Screens.Definitions.register(
            group_id: 'foo', model: 'Hippo.Test.DefinitionTestModel', id: 'screen'
        )
        group = Hippo.Screens.Definitions.groups.first()
        expect(group).not.toBe(null)

        expect(Hippo.Screens.Definitions.groups.available().length).toEqual(1)
        expect( group.screens().length ).toEqual(1)

        Hippo.current_user.hasAccess = -> false
        Hippo.current_user.isLoggedIn = false

        expect( group.screens().length ).toEqual(0)
        expect( Hippo.Screens.Definitions.groups.available().length ).toEqual(0)
