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
        <BS.Button navItem componentClass="button" disabled={!@isSavable()}
            onClick={@props.commands.saveModel} className="save navbar-btn control">
            <i className="icon icon-cloud-upload" />Save
        </BS.Button>

    renderResetButton: ->
        <BS.Button navItem componentClass="button"
            onClick={@props.commands.resetModel} className="save navbar-btn control">
            <i className="icon icon-undo" />Reset
        </BS.Button>

    renderEditToggle: ->
        <form className="control navbar-form navbar-left">
           <label>
               <Lanes.Vendor.ReactToggle
               aria-labelledby="Editing"
               onChange={@props.commands.toggleEdit}
               defaultChecked={@props.commands.isEditing()} />
               <span className="label-text">Edit</span>
           </label>
        </form>

    isSavable: ->
        if @props.commands.saveModel
            if @props.commands.toggleEdit
                @props.commands.isEditing()
            else
                true
        else
            false

    renderSpacer: ->
        <span className="control spacer" />

    render: ->
        <BS.Navbar className="lanes-toolbar">
          <BS.Nav>
            {@renderSaveButton()}
            {@renderResetButton()}
            {@renderEditToggle() if @props.commands.toggleEdit}
          </BS.Nav>
          <LC.Toolbar.RemoteChangeSets model=@changedModel />
        </BS.Navbar>
