import React from 'react';

export class ResizeSensor extends BaseComponent {
    static propTypes =
        {onResize: React.PropTypes.func.isRequired};
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
