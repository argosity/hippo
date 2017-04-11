import React from 'react';

import PropTypes from 'prop-types';

export class ResizeSensor extends BaseComponent {
    static propTypes =
        {onResize: PropTypes.func.isRequired};
    render() {
        return (
            <Lanes.Vendor.ComponentResize
                {...this.props}
                embedCss={false}
                export className={_.classnames('lanes-resize-sensor', this.props.className)}>
                {this.props.children}
            </Lanes.Vendor.ComponentResize>
        );
    }
}
