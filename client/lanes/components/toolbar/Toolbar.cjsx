##= require_self
##= require ./SaveButton

class Lanes.Components.Toolbar extends Lanes.React.Component

    propTypes:
        toggleEdit: Lanes.PropTypes.Model
        commands: React.PropTypes.object.isRequired

    modelBindings:
        model: 'props'

    bindEvents:
        changedModel: 'remote-update isSavable'

    EditToggle: ->
        return null unless @props.commands.canEditModel()
        <li className="toggle control">
            <label>
                <Lanes.Vendor.ReactToggle
                    aria-labelledby="Editing"
                    onChange={@props.commands.toggleEdit}
                    checked={@props.commands.isEditing()} />
                <span>Edit</span>
            </label>
        </li>

    renderSpacer: ->
        <span className="control spacer" />

    render: ->
        <BS.Nav bsStyle="pills" className="lanes-toolbar">
            <Lanes.Components.Toolbar.SaveButton commands={@props.commands} />
            <BS.NavItem
                onClick={@props.commands.resetModel}
                className="reset navbar-btn control">
                <LC.Icon type="undo" />Reset
            </BS.NavItem>
            {@props.children}
            <BS.NavItem className="spacer" />

            <@EditToggle />
            <LC.Toolbar.RemoteChangeSets model=@model />
        </BS.Nav>
