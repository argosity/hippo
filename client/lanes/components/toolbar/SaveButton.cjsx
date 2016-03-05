class Lanes.Components.Toolbar.SaveButton extends Lanes.React.Component

    propTypes:
        commands: React.PropTypes.object.isRequired

    onSave: ->
        model = @props.commands.getModel()
        if @isSavable(model)
            @props.commands.saveModel()
        else
            model.unmaskInvalidField('all')

    isSavable: (model) ->
        if @props.commands.saveModel
            @props.commands.isEditing() and model.isSavable
        else
            false

    render: ->
        return null unless @props.commands.canEditModel()
        model = @props.commands.getModel()
        text = if model.isNew() then 'Create' else 'Save'
        classNames = _.classnames('save', 'navbar-btn', 'control', {disabled: !@isSavable(model)})
        <BS.Button navItem componentClass="button"
            onClick={@onSave} className={classNames} >
            <LC.Icon type="cloud-upload" />{text}
        </BS.Button>
