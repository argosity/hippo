Foptions = [
    { value: 'one', label: 'One' },
    { value: 'two', label: 'Two' }
    { value: 'three', label: 'Three' }
    { value: 'four', label: 'Four' }
]

class Lanes.Access.Screens.UserManagement extends Lanes.React.Screen

    getInitialState: ->
        fields = [
            {id:'id', visible: false}
            'login', 'name', 'email', {id:'role_names', title:'Role Names'}
        ]
        query: new Lanes.Models.Query({
            fields: fields, modelClass: Lanes.Models.User
        })

    editors: (props) ->
        role_names:
            <LC.SelectField
                id="role_names"
                key="row-select"
                multi=true
                name="form-field-name"
                value="one"
                options={Foptions}
            />

    render: ->
        <div>
            <h1>Users Management</h1>
            <input type="text" defaultValue={@props.cid}/>
            <LC.Grid
                query={@state.query}
                editors={@editors()}
                ref="grid"/>
        </div>
