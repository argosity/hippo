import React from 'react';
import PropTypes from 'prop-types';
import invariant from 'invariant';
import { action } from 'mobx';
import { inject, observer } from 'mobx-react';
import classnames from 'classnames';
import { Col, getColumnProps } from 'react-flexbox-grid';
import Field     from 'grommet/components/FormField';
import NumberInput from 'grommet/components/NumberInput';
import { titleize } from '../../lib/util';
import DateWrapper     from './fields/date-wrapper';
import SelectWrapper   from './fields/select-wrapper';
import TextWrapper     from './fields/text-wrapper';
import CheckBoxWrapper from './fields/checkbox-wrapper';
import Label           from './fields/label';
import TimeZoneSelect  from '../../components/time-zone-select';

import './fields/form-field.scss';

const TypesMapping = {
    text:     TextWrapper,
    date:     DateWrapper,
    label:    Label,
    select:   SelectWrapper,
    number:   NumberInput,
    timezone: TimeZoneSelect,
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
            name, className, autoFocus, type, children, label,
            validate: _, formState: __, help: ___, ...otherProps
        } = getColumnProps(this.props);

        const InputTag = TypesMapping[type] || TypesMapping.text;

        return (
            <div className={classnames('form-field', className)}>
                <Field
                    label={label || titleize(name)}
                    error={this.field.invalidMessage}
                    help={this.field.help}
                >
                    <InputTag
                        name={name}
                        autoFocus={autoFocus}
                        ref={this.setRef}
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
