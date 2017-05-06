import React from 'react';

import { Provider, observer } from 'mobx-react';

import FormFields from './model';

@observer
export default class FormWrapper extends React.PureComponent {

    static propTypes = {
        children: React.PropTypes.node.isRequired,
        fields: React.PropTypes.instanceOf(FormFields),
        tag: React.PropTypes.string,
        className: React.PropTypes.string,
    }

    renderTagless() {
        return (
            <Provider formFields={this.props.fields}>
                {this.props.children}
            </Provider>
        );
    }

    renderTagged() {
        const { tag: Tag, fields, children, ...otherProps } = this.props;
        return (
            <Provider formFields={fields}>
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
