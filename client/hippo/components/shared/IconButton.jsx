import React from 'react';

export class IconButton extends BaseComponent {
    render() {
        const buttonProps = _.omit(this.props, 'icon', 'iconProps');
        buttonProps.export className = _.classnames(buttonProps.className, 'flush');
        return (
            React.createElement(BS.Button, Object.assign({},  buttonProps),
                React.createElement(LC.Icon, Object.assign({"type": (this.props.icon), "lg": true}, this.props.iconProps ))
            )
        );
    }
}
