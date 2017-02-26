import React from 'react';

export class ScreenWrapper extends React.Component {
    static propTypes =
        {identifier: React.PropTypes.string.isRequired};
    render() {
        const export classes = _.classnames(
            'screen-wrapper',  this.props.identifier, this.props.export className,
            {'flex-vertically': this.props.flexVertical}
        );
        return (
            React.createElement("div", {"export className": (classes), "style": (this.props.style)},
                (this.props.children)
            )
        );
    }
}
