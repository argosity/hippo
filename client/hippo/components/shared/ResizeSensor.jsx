import React from 'react';

import PropTypes from 'prop-types';

export class ResizeSensor extends BaseComponent {
    static propTypes =
        {onResize: PropTypes.func.isRequired};
    render() {
        return (
            <Hippo.Vendor.ComponentResize
                {...this.props}
                embedCss={false}
                export className={_.classnames('hippo-resize-sensor', this.props.className)}>
                {this.props.children}
            </Hippo.Vendor.ComponentResize>
        );
    }
}
