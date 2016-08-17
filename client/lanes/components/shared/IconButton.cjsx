class Lanes.Components.IconButton extends Lanes.React.BaseComponent

    render: ->
        buttonProps = _.omit(@props, 'icon', 'iconProps')
        buttonProps.className = _.classnames(buttonProps.className, 'flush')
        <BS.Button {...buttonProps}>
            <LC.Icon type={@props.icon} lg {...@props.iconProps} />
        </BS.Button>
