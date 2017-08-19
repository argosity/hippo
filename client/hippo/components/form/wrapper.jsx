import React from 'react';
import PropTypes from 'prop-types';
import { PropTypes as MobxPropTypes, Provider, observer } from 'mobx-react';
import { observePubSub } from '../../models/pub_sub';
import { FormState } from './api';

@observer
export default class FormWrapper extends React.PureComponent {
    static propTypes = {
        tag: PropTypes.string,
        className: PropTypes.string,
        children: PropTypes.node.isRequired,
        state: PropTypes.instanceOf(FormState),
        model: MobxPropTypes.observableObject,
    }

    static get defaultProps() {
        return {
            state: new FormState(),
        };
    }

    componentDidMount() {
        if (this.props.model) {
            this.props.state.setFromModel(this.props.model);
        }
    }

    renderTagless() {
        return (
            <Provider formState={this.props.state}>
                {this.props.children}
            </Provider>
        );
    }

    persistTo(model) {
        this.props.state.persistTo(model);
    }

    renderTagged() {
        const { tag: Tag, state, children, model: _, ...otherProps } = this.props;
        return (
            <Provider formState={state}>
                <Tag {...otherProps}>
                    {children}
                </Tag>
            </Provider>
        );
    }

    render() {
        if (this.props.model) { observePubSub(this.props.model); }
        return this.props.tag ? this.renderTagged() : this.renderTagless();
    }
}
