import React from 'react';
import classnames from 'classnames';
import { observer }   from 'mobx-react';

import ScreenInstance from '../screens/instance';

@observer
export default class Screen extends React.Component {
    static defaultProps = {
        className: '',
    }

    static propTypes = {
        screen:    React.PropTypes.instanceOf(ScreenInstance).isRequired,
        children:  React.PropTypes.node.isRequired,
        className: React.PropTypes.string,
    }

    render() {
        return (
            <div
                data-screen-id={this.props.screen.definition.id}
                className={classnames('screen', this.props.className, {
                                   'is-active': this.props.screen.isActive,
                    })}
            >
                {this.props.children}
            </div>
        );
    }
}
