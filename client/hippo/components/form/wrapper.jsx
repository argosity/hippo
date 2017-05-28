import React from 'react';

import { Provider, observer } from 'mobx-react';

import { FormState } from './model';

@observer
export default class FormWrapper extends React.PureComponent {

    static propTypes = {
        children: React.PropTypes.node.isRequired,
        state: React.PropTypes.instanceOf(FormState),
        tag: React.PropTypes.string,
        className: React.PropTypes.string,
    }

    static get defaultProps() {
        return {
            state: new FormState(),
        };
    }

    renderTagless() {
        return (
            <Provider formState={this.props.state}>
                {this.props.children}
            </Provider>
        );
    }

    renderTagged() {
        const { tag: Tag, state, children, ...otherProps } = this.props;
        return (
            <Provider formState={state}>
                <Tag {...otherProps}>
                    {children}
                </Tag>
            </Provider>
        );
    }

    render() {
        return this.props.tag ? this.renderTagged() : this.renderTagless();
    }

}
