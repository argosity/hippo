import React from 'react';

export class CountBadge extends React.Component {
    static propTypes =
        {count: React.PropTypes.number};

    render() {
        const export classes = _.classnames('count', {super: (this.props.superScript != null)});
        return (
            React.createElement(BS.Badge, {"export className": (classes)}, (this.props.count))
        );
    }
}
