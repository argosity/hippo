import React from 'react';
import PropTypes from 'prop-types';
import { observer } from 'mobx-react';
import { get, partial, map, find } from 'lodash';
import classnames from 'classnames';
import { Col, getColumnProps } from 'react-flexbox-grid';
import Field     from 'grommet/components/FormField';
import TextInput from 'grommet/components/TextInput';
import NumberInput from 'grommet/components/NumberInput';
import DateTime  from 'grommet/components/DateTime';
import Select from 'grommet/components/Select';
import moment from 'moment';
import { titleize } from '../lib/util';

import './form-field.scss';
import FieldValidation from './field-validation';

class TextWrapper extends React.PureComponent {
    focus() {
        this.inputRef.componentRef.focus();
    }
    render() {
        return (
            <TextInput
                ref={f => (this.inputRef = f)}
                {...this.props} onDOMChange={this.props.onChange}
            />
        );
    }
}

class DateWrapper extends React.PureComponent {
    static defaultProps = {
        format: 'M/D/YYYY h:mm a',
    }
    onDateChange(date) {
        this.props.onChange({ target: { value: moment(date, this.props.format).toDate() } });
    }
    render() {
        return <DateTime {...this.props} onChange={this.onDateChange} />;
    }
}

@observer
class SelectFieldWrapper extends React.PureComponent {
    onSelectChange({ value: { id } }) {
        this.props.onChange({ target: { value: id } });
    }
    render() {
        const { collection, value, ...otherProps } = this.props;
        return (
            <Select
                {...otherProps}
                value={value ? get(find(collection, { id: value }), 'label', '') : ''}
                options={collection}
                onChange={this.onSelectChange}
            />
        );
    }
}

const TypesMapping = {
    text:   TextWrapper,
    date:   DateWrapper,
    select: SelectFieldWrapper,
    number: NumberInput,
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
                        {...field.events}
                        {...otherProps}
                    />
                    {children}
                </Field>
            </div>
        );
    }
}
