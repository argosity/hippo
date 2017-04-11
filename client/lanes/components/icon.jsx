import React from 'react';

import PropTypes from 'prop-types';

import { uniqueId, extend } from 'lodash';
import classnames from 'classnames';

const DEFAULT_TOOLTIP_PROPS = { placement: 'top', trigger: 'click' };

export default class Icon extends React.Component {

    static propTypes = {
        type:         PropTypes.string.isRequired,
        animated:     PropTypes.bool,
        spinner:      PropTypes.bool,
        className:    PropTypes.string,
        tooltip:      PropTypes.oneOfType([
            PropTypes.string, PropTypes.element
        ]),
        tooltipProps: PropTypes.object,
    };

    static defaultProps = {
        tooltipProps: DEFAULT_TOOLTIP_PROPS,
    }

    constructor(props) {
        super(props);
        this.state = {
            uniqueId: uniqueId('icon-tooltip-'),
        };
    }

    render() {
        const classes = classnames('icon', `icon-${this.props.type}`, this.props.className, {
            'non-printable': this.props.noPrint,
            'with-action' : this.props.onClick,
            [`icon-${this.props.size}`] : this.props.size,
            'icon-pulse' : this.props.animated,
            'icon-spin'  : this.props.spin || (this.props.type === 'spinner'),
            'flush'      : this.props.flush,
            'icon-lg'    : this.props['lg'],
            'icon-2x'    : this.props['2x'],
            'icon-3x'    : this.props['3x'],
            'icon-4x'    : this.props['4x'],
            'icon-5x'    : this.props['5x'],
            'clickable'  : this.props.clickable || (this.props.tooltip && (this.props.tooltipProps.trigger === 'click'))
        }
        );

        const icon =
            React.createElement("i", {"style": (this.props.style), "className": (classes), "onClick": (this.props.onClick)});

        if (this.props.tooltip) {
            const props = extend({}, DEFAULT_TOOLTIP_PROPS, this.props.tooltipProps);
            return (
                React.createElement(LC.Tooltip, Object.assign({"id": (this.state.uniqueId),
                    "content": (this.props.tooltip)
                    }, props
                ),
                    (icon)
                )
            );
        } else {
            return (
                icon
            );
        }
    }
}
