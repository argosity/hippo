describe "Hippo.Models.EnumMap", ->
    model = null

    beforeEach ->
        model = Hippo.Test.makeModel({
            enums:
                state:
                    open: 1
                    complete: 5
                    canceled: 9

            props:
                state: {"type":"integer"}

        },{ id: 123 })

    it "sets up enums", ->
        expect(model.is_open).toEqual(false)
        model.state = 1
        expect(model.is_open).toEqual(true)
        model.is_open="some crazy value"
        expect(model.is_open).toEqual(true)

    it "reads the enum's value from the field", ->
        model.state = 1
        expect(model.state_value).toEqual("open")
