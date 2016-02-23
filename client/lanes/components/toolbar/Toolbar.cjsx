class Lanes.Components.Toolbar extends Lanes.React.Component

    propTypes:
        onSave: React.PropTypes.func
        toggleEdit: Lanes.PropTypes.Model
        commands: React.PropTypes.object.isRequired

    dataObjects:
        changedModel: -> @props.commands.getModel()

    bindDataEvents:
        changedModel: 'remote-update isSavable'

    onSave: ->
        model = @props.commands.getModel()
        if @isSavable(model)
            @props.commands.saveModel()
        else
            model.unmaskInvalidFields('all')

    renderSaveButton: ->
        model = @props.commands.getModel()
        text = if model.isNew() then 'Create' else 'Save'
        classNames = _.classnames('save', 'navbar-btn', 'control', {disabled: !model.isSavable})
        <BS.Button navItem componentClass="button"
            onClick={@onSave} className={classNames} >
            <LC.Icon type="cloud-upload" />{text}
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

    isSavable: (model) ->
        if @props.commands.saveModel
            @props.commands.isEditing() and model.isSavable
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
