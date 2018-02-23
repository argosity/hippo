import React from 'react';
import PropTypes from 'prop-types';
import invariant from 'invariant';
import { isString, invoke } from 'lodash';
import { action } from 'mobx';
import { inject, observer } from 'mobx-react';
import FieldWrapper     from './field-wrapper';
import DateWrapper     from './fields/date-wrapper';
import SelectWrapper   from './fields/select-wrapper';
import TextWrapper     from './fields/text-wrapper';
import EmailWrapper    from './fields/email-wrapper';
import CheckBoxWrapper from './fields/checkbox-wrapper';
import TextAreaWrapper from './fields/textarea-wrapper';
import Label           from './fields/label';
import TimeZoneSelect  from '../../components/time-zone-select';

const TypesMapping = {
    email:    EmailWrapper,
    text:     TextWrapper,
    date:     DateWrapper,
    label:    Label,
    select:   SelectWrapper,
    number:   TextWrapper,
    timezone: TimeZoneSelect,
    checkbox: CheckBoxWrapper,
    textarea: TextAreaWrapper,
};

@inject('formState')
@observer
export default class FormField extends React.Component {

    static propTypes = {
        label: PropTypes.string,
        name:  PropTypes.string.isRequired,
        className: PropTypes.string,
        tabIndex: PropTypes.number,
    }

    static defaultProps = {
        label:     '',
        className: '',
        type:      'text',
        tabIndex: 0,
    }
    focus() {
        if (this.inputRef) { this.inputRef.focus(); }
    }

    componentWillMount() {
        this.field = this.props.formState.setField(this.props.name, this.props);
    }

    componentWillReceiveProps(nextProps) {
        invariant(nextProps.name === this.props.name,
            `cannot update 'name' prop from ${this.props.name} to ${nextProps.name}`);
        this.field.update(this.props);
    }

    @action.bound
    setRef(input) {
        this.inputRef = input;
    }

    render() {
        const {
            name, control, className, autoFocus, type, children, label, tabIndex,
            validate: _, formState: __, help: ___,
            width, cellWidth, desktop, tablet, phone, height,
            left, top, middle, center, area,
            ...otherProps
        } = this.props;
        const wrapperProps = {
            width, desktop, tablet, phone, cellWidth, height, left, top, middle, center, area, type,
        };
        const InputTag = isString(type) ? (
            TypesMapping[type] || TypesMapping.text
        ) : type;

        return (
            <FieldWrapper
                label={label}
                name={name}
                error={this.field.invalidMessage}
                help={this.field.help}
                className={className}
                type={type}
                {...wrapperProps}
                styles={invoke(type, 'styles', this.props)}
                control={control}
            >
                <InputTag
                    plain
                    name={name}
                    tabIndex={tabIndex}
                    autoFocus={autoFocus}
                    ref={this.setRef}
                    value={this.field.value || ''}
                    type={type}
                    {...this.field.events}
                    {...otherProps}
                />
                {control}
                {children}
            </FieldWrapper>
        );
    }

}
