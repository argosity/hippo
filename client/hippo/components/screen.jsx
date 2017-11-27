import React from 'react';
import PropTypes from 'prop-types';
import classnames from 'classnames';
import { observer }   from 'mobx-react';

import ScreenInstance from '../screens/instance';

@observer
export default class Screen extends React.Component {

    static Instance = ScreenInstance;

    static defaultProps = {
        className: '',
    }

    static propTypes = {
        screen:    PropTypes.instanceOf(ScreenInstance).isRequired,
        children:  PropTypes.node.isRequired,
        className: PropTypes.string,
    }

    render() {
        return (
            <div
                data-screen-id={this.props.screen.definition.id}
                className={classnames(
                    'hippo-screen',
                    this.props.screen.definition.id,
                    this.props.className, {
                        'is-active': this.props.screen.isActive,
                    },
                )}
            >
                {this.props.children}
            </div>
        );
    }

}
