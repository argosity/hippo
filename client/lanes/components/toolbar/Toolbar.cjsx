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
            <LC.Icon type="cloud-upload" />{@props.saveButtonText || 'Save'}
        </BS.Button>

    renderResetButton: ->
        <BS.Button navItem componentClass="button"
            onClick={@props.commands.resetModel} className="save navbar-btn control">
            <LC.Icon type="undo" />Reset
        </BS.Button>

    renderPrintButton: ->
        <BS.Button navItem componentClass="button"
            onClick={@props.commands.printModel} className="print navbar-btn control">
            <LC.Icon type="print" />Print
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
                {@renderPrintButton() if @props.commands.canPrint()}
                {@renderEditToggle()  if @props.commands.toggleEdit}
            </BS.Nav>
            <LC.Toolbar.RemoteChangeSets model=@changedModel />
            {@props.children}
        </BS.Navbar>
