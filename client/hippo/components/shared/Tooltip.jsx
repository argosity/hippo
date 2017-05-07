import React from 'react';

export default class Tooltip extends React.Component {
    static TTProps = [
        'id', 'placement', 'positionLeft', 'positionTop',
        'arrowOffsetLeft', 'arrowOffsetTop'
    ];
    render() {
        const ttprops = _.pick(this.props, ...this.TTProps);
        const tooltip = <BS.Tooltip {...ttprops}>
            {this.props.content}
        </BS.Tooltip>;
        return (
            <BS.OverlayTrigger
                overlay={tooltip}
                placement="left"
                container={this.context.viewport.hippo}
                {...this.props}>
                {this.props.children}
            </BS.OverlayTrigger>
        );
    }
}
