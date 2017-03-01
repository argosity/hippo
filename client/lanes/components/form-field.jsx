import React from 'react';
import { get } from 'lodash';
import classnames from 'classnames';
import { observer } from 'mobx-react';
import { Col } from 'react-flexbox-grid';
import { titleize } from '../lib/util';
import Field from 'grommet/components/FormField';
import TextInput from 'grommet/components/TextInput';

import './form-field.scss';

export default class FormField extends React.Component {
    static defaultProps = {
        label:     '',
        className: '',
    }

    static propTypes = {
        label: React.PropTypes.string,


        name:  React.PropTypes.string.isRequired,
        field: React.PropTypes.shape({
            events: React.PropTypes.object.isRequired,
            value:  React.PropTypes.string.isRequired,
        }).isRequired,
        className: React.PropTypes.string,
    }

    render() {
        const { field, name, className, autoFocus, type, ...otherProps } = this.props;
        const label = this.props.label || titleize(name);
        return (
            <Col {...otherProps} className={classnames('form-field', className)}>
                <Field label={label} error={get(field, 'failProps.errorText')}>
                    <TextInput
                        name={name}
                        type={type}
                        autoFocus={autoFocus}
                        value={field.value}
                        {...field.events}
                        onDOMChange={field.events.onChange}
                    />
                </Field>
            </Col>
        );
    }
}
