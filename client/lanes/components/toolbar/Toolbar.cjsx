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
        <li navItem className="toggle control">
           <label>
               <Lanes.Vendor.ReactToggle
               aria-labelledby="Editing"
               onChange={@props.commands.toggleEdit}
               defaultChecked={@props.commands.isEditing()} />
               <span>Edit</span>
            </label>
        </li>

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
        <BS.Nav bsStyle="pills" className="lanes-toolbar">
            {@renderSaveButton()}
            {@renderResetButton()}
            {@renderPrintButton() if @props.commands.canPrint()}
            {@props.children}
            <div className="spacer"/>
            {@renderEditToggle()  if @props.commands.toggleEdit}
            <LC.Toolbar.RemoteChangeSets model=@changedModel />
        </BS.Nav>
