class Lanes.Components.Grid.PopoverEditor extends Lanes.React.Component

    mixins: [
        Lanes.Components.Grid.PopoverMixin
    ]

    renderBody: ->
        <form>
            {@renderFields()}
            {@renderControls()}
        </form>

    render: ->
        @renderPopover()
