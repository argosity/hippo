class Lanes.Components.FieldWrapper extends Lanes.React.BaseComponent

    mixins: [
        Lanes.React.Mixins.Access
        Lanes.React.Mixins.FieldErrors
        Lanes.React.Mixins.ReadEditingState
    ]
    blankElement: 'span'
    propTypes:
        model:    Lanes.PropTypes.State.isRequired
        unlabeled: React.PropTypes.bool
        displayComponent: React.PropTypes.any.isRequired
        label: React.PropTypes.oneOfType([
            React.PropTypes.string, React.PropTypes.element
        ])

    renderLabel: ->
        return null if @props.unlabeled
        <BS.ControlLabel>
            {@props.label}
        </BS.ControlLabel>

    renderType: ->
        if @isEditingRecord()
            if @hasWriteAccess()
                ['edit', @props.children]
            else if @hasReadAccess()
                ['display']
            else
                ['none', @blankElement]
        else
            if @hasReadAccess()
                ['display']
            else
                ['none', @blankElement]

    render: ->
        [type, child] = @renderType()

        props = _.omit(@props,
            'value', 'model', 'value', 'label', 'name', 'displayComponent'
        )
        unless child
            Comp = @props.displayComponent
            child = <Comp props />

        if @isFieldValueInvalid()
            validationState = 'warning'

        if (invalidMsg = @fieldInvalidValueMessage())
            msg = <BS.HelpBlock>{invalidMsg}</BS.HelpBlock>

        className = _.classnames( 'lanes-field', type, @props.className
            ( if @props.align then "align-#{@props.align}" else null),
        )

        <BS.Col {...props} className={className}>
            <BS.FormGroup validationState={validationState}>
                <BS.ControlLabel>
                {@renderLabel()}
                </BS.ControlLabel>
                {child}
                <BS.FormControl.Feedback />
                {msg}
            </BS.FormGroup>
        </BS.Col>
