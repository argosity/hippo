##= require_self
##= require ./SaveButton

class Lanes.Components.Toolbar extends Lanes.React.Component

    propTypes:
        toggleEdit: Lanes.PropTypes.Model
        commands: React.PropTypes.object.isRequired

    dataObjects:
        changedModel: -> @props.commands.getModel()

    bindDataEvents:
        changedModel: 'remote-update isSavable'

    renderResetButton: ->
        <BS.Button navItem componentClass="button"
            onClick={@props.commands.resetModel} className="reset navbar-btn control">
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

    renderSpacer: ->
        <span className="control spacer" />

    render: ->
        <BS.Nav bsStyle="pills" className="lanes-toolbar">
            <Lanes.Components.Toolbar.SaveButton commands={@props.commands} />
            {@renderResetButton()}
            {@renderPrintButton() if @props.commands.canPrint?()}
            {@props.children}
            <div className="spacer"/>
            {@renderEditToggle()  if @props.commands.toggleEdit}
            <LC.Toolbar.RemoteChangeSets model=@changedModel />
        </BS.Nav>
