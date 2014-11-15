describe "Choices Input Suite", ->

    it "renders to a view", ->
        roles = new Lanes.Data.Roles([
            {id: 'one', name:'One'}
            {id: 'two', name:'Two'}
        ])
        sf = new Lanes.Component.SelectField({
            multiple: true, data: roles, mappings:{ title: 'name', selected: 'member' }
        })
        sf.render().el
        expect( sf.$('option').length ).toEqual(2)
