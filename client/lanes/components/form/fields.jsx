import React from 'react';
import PropTypes from 'prop-types';

import { inject, observer } from 'mobx-react';
import classnames from 'classnames';
import { Col, getColumnProps } from 'react-flexbox-grid';

import Field     from 'grommet/components/FormField';
import NumberInput from 'grommet/components/NumberInput';

import { titleize } from '../../lib/util';
import FormFieldPropType from './field-prop-type';

import DateWrapper     from './fields/date-wrapper';
import SelectWrapper   from './fields/select-wrapper';
import TextWrapper     from './fields/text-wrapper';
import CheckBoxWrapper from './fields/checkbox-wrapper';

import './fields/form-field.scss';

const TypesMapping = {
    text:     TextWrapper,
    date:     DateWrapper,
    select:   SelectWrapper,
    number:   NumberInput,
    checkbox: CheckBoxWrapper,

};

@inject('formFields') @observer
export default class FormField extends React.PureComponent {
    static defaultProps = {
        label:     '',
        className: '',
        type:      'text',
    }

    focus() {
        if (this.inputRef) { this.inputRef.focus(); }
    }

    static propTypes = Object.assign({
        label: PropTypes.string,
        name:  PropTypes.string.isRequired,
        formFields: FormFieldPropType,
        className: PropTypes.string,
        type: PropTypes.string,
    }, Col.PropTypes)

    render() {
        const {
            name, className, autoFocus, type, children, label, formFields, ...otherProps
        } = getColumnProps(this.props);
        const InputTag = TypesMapping[type] || TypesMapping.text;
        const field = formFields.get(name);
        return (
            <div className={classnames('form-field', className)}>
                <Field
                    label={label || titleize(name)}
                    error={field.invalidMessage}
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
