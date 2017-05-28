import React from 'react';
import PropTypes from 'prop-types';

import { inject, observer } from 'mobx-react';
import classnames from 'classnames';
import { Col, getColumnProps } from 'react-flexbox-grid';

import invariant from 'invariant';
import Field     from 'grommet/components/FormField';
import NumberInput from 'grommet/components/NumberInput';

import { titleize } from '../../lib/util';

import { FormField as FormFieldModel }   from './model';
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


@inject('formState')
@observer
export default class FormField extends React.PureComponent {
    static propTypes = Object.assign({
        label: PropTypes.string,
        name:  PropTypes.string.isRequired,
        className: PropTypes.string,
        type: PropTypes.string,
    }, Col.PropTypes)

    static defaultProps = {
        label:     '',
        className: '',
        type:      'text',
    }

    field = new FormFieldModel(this.props.name, this.props);

    focus() {
        if (this.inputRef) { this.inputRef.focus(); }
    }

    componentWillMount() {
        this.props.formState.fields.set(this.props.name, this.field);
    }

    componentWillReceiveProps(nextProps) {
        invariant(nextProps.name === this.props.name,
                  `cannot update 'name' prop from ${this.props.name} to ${nextProps.name}`);
        this.field.update(this.props);
    }

    render() {
        const {
            name, className, autoFocus, type, children, label,
            validate: _, formState: __, ...otherProps
        } = getColumnProps(this.props);
        const InputTag = TypesMapping[type] || TypesMapping.text;

        return (
            <div className={classnames('form-field', className)}>
                <Field
                    label={label || titleize(name)}
                    error={this.field.invalidMessage}
                    help={this.field.helpMessage}
                >
                    <InputTag
                        name={name}
                        autoFocus={autoFocus}
                        ref={f => (this.inputRef = f)}
                        value={this.field.value || ''}
                        type={InputTag === TypesMapping.text ? this.props.type : undefined}
                        {...this.field.events}
                        {...otherProps}
                    />
                    {children}
                </Field>
            </div>
        );
    }
}
