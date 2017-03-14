import React from 'react';
import { get } from 'lodash';
import classnames from 'classnames';
import { observer } from 'mobx-react';
import { Col, getColumnProps } from 'react-flexbox-grid';
import { titleize } from '../lib/util';
import Field from 'grommet/components/FormField';
import TextInput from 'grommet/components/TextInput';

import './form-field.scss';
import FieldValidation from './field-validation';

export default class FormField extends React.PureComponent {
    static defaultProps = {
        label:     '',
        className: '',
        fields:    null,
    }

    static propTypes = Object.assign({
        label: React.PropTypes.string,
        name:  React.PropTypes.string.isRequired,
        fields: FieldValidation,
        className: React.PropTypes.string,
    }, Col.PropTypes)

    render() {
        const {
            name, className, autoFocus, type, children, label,
            fields: { [`${name}`]: field },
            ...otherProps
        } = getColumnProps(this.props);

        return (
            <div className={classnames('form-field', className)}>
                <Field
                    label={label || titleize(name)}
                    error={get(field, 'failProps.errorText')}
                >
                    <TextInput
                        name={name}
                        type={type}
                        autoFocus={autoFocus}
                        value={field.value}
                        {...otherProps}
                        {...field.events}
                        onDOMChange={field.events.onChange}
                    />
                    {children}
                </Field>
            </div>
        );
    }
}
