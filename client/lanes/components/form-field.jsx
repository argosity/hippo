import React from 'react';
import PropTypes from 'prop-types';

import { get } from 'lodash';
import classnames from 'classnames';
import { Col, getColumnProps } from 'react-flexbox-grid';

import Field     from 'grommet/components/FormField';
import NumberInput from 'grommet/components/NumberInput';

import { titleize } from '../lib/util';

import FieldValidation from './field-validation';

import DateWrapper     from './form-field/date-wrapper';
import SelectWrapper   from './form-field/select-wrapper';
import TextWrapper     from './form-field/text-wrapper';
import CheckBoxWrapper from './form-field/checkbox-wrapper';

import './form-field/form-field.scss';

const TypesMapping = {
    text:     TextWrapper,
    date:     DateWrapper,
    select:   SelectWrapper,
    number:   NumberInput,
    checkbox: CheckBoxWrapper,

};


export default class FormField extends React.PureComponent {
    static defaultProps = {
        label:     '',
        className: '',
        fields:    null,
        type:      'text',
    }

    focus() {
        if (this.inputRef) { this.inputRef.focus(); }
    }

    static propTypes = Object.assign({
        label: PropTypes.string,
        name:  PropTypes.string.isRequired,
        fields: FieldValidation,
        className: PropTypes.string,
        type: PropTypes.string,
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
                        ref={f => (this.inputRef = f)}
                        value={field.value || ''}
                        type={InputTag === TypesMapping.text ? this.props.type : undefined}
                        {...field.events}
                        {...otherProps}
                    />
                    {children}
                </Field>
            </div>
        );
    }
}
