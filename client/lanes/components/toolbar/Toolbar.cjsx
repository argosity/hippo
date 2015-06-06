class Lanes.Components.Toolbar extends Lanes.React.Component

    propTypes:
        onSave: React.PropTypes.func
        toggleEdit: Lanes.PropTypes.Model
        commands: React.PropTypes.object.isRequired

    dataObjects:
        changedModel: -> @props.commands.getModel()

    bindDataEvents:
        changedModel: 'remote-update'

    renderSaveButton: ->
        <BS.Button
            navItem
            componentClass="button"
            onClick={@props.commands.saveModel}
            className="save navbar-btn"
        >
            <i className="icon icon-cloud-upload" />Save
        </BS.Button>

    renderEditToggle: ->
        <form className="navbar-form navbar-left" role="search">
            <div className="form-group">
                <label>
                    <input type="checkbox" className="form-control"
                        checked={@props.commands.isEditing()}
                        onChange={@props.commands.toggleEdit} />
                    Edit
                </label>
            </div>
        </form>

    isSavable: ->
        if @props.commands.saveModel
            if @props.commands.toggleEdit
                @props.commands.isEditing()
            else
                true
        else
            false

    render: ->
        <BS.Navbar className="lanes-toolbar">
          <BS.Nav>
            {@renderEditToggle() if @props.commands.toggleEdit}
            {@renderSaveButton() if @isSavable()}
          </BS.Nav>
          <LC.Toolbar.RemoteChangeSets model=@changedModel />
        </BS.Navbar>
