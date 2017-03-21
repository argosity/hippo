import React from 'react';
import { get, partial } from 'lodash';
import classnames from 'classnames';
import { Col, getColumnProps } from 'react-flexbox-grid';
import Field     from 'grommet/components/FormField';
import TextInput from 'grommet/components/TextInput';
import DateTime  from 'grommet/components/DateTime';

import { titleize } from '../lib/util';

import './form-field.scss';
import FieldValidation from './field-validation';

const Text = props =>
    <TextInput {...props} onDOMChange={props.onChange} />;
const onDateChange = (props, date) =>
    props.onChange({ target: { value: date } });
const Date = props =>
    <DateTime {...props} onChange={partial(onDateChange, props)} />;

const TypesMapping = {
    text: Text,
    date: Date,
};

export default class FormField extends React.PureComponent {
    static defaultProps = {
        label:     '',
        className: '',
        fields:    null,
        type:      'text',
    }

    static propTypes = Object.assign({
        label: React.PropTypes.string,
        name:  React.PropTypes.string.isRequired,
        fields: FieldValidation,
        className: React.PropTypes.string,
        type: React.PropTypes.string,
    }, Col.PropTypes)

    render() {
        const {
            name, className, autoFocus, type, children, label,
            fields: { [`${name}`]: field },
            ...otherProps
        } = getColumnProps(this.props);
        const InputTag = TypesMapping[type] || TypesMapping.text;
        return (
            <div className={classnames('form-field', className)}>
                <Field
                    label={label || titleize(name)}
                    error={get(field, 'failProps.errorText')}
                >
                    <InputTag
                        name={name}
                        autoFocus={autoFocus}
                        value={field.value}
                        {...otherProps}
                        {...field.events}
                    />
                    {children}
                </Field>
            </div>
        );
    }
}
