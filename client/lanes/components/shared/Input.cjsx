class Lanes.Components.Input extends Lanes.React.Component

    mixins: [
        Lanes.Components.Form.FieldMixin
    ]
    formGroupClass: 'input'

    getDefaultProps: ->
        type: 'text'

    propTypes:
        unlabled:  React.PropTypes.bool

    getValue: ->
        @refs.input.getValue()

    handleKeyDown: (ev) ->
        @props.onEnter() if ev.key is 'Enter'

    renderEdit: (label) ->
        value = @props.model[@props.name] or ''
        props = _.extend({
            ref:       'input'
            className: _.classnames('value', changeset: @state.changeset)
            label:     if @props.unlabeled then label else false
            value:     value
            onKeyDown: @handleKeyDown if @props.onEnter
            onChange:  @handleChange
        }, @props)

        if @props.inputOnly then @renderPlain(props) else @renderStyled(props, label)

    renderPlain: (props) ->
        <input {...props}/>

    renderStyled: (props, label) ->
        colProps = _.omit(props, 'name')
        <BS.Col {...colProps} >
            <BS.Input {...props} />
        </BS.Col>
