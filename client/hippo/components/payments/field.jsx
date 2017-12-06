import React from 'react';
import FieldWrapper from 'grommet/components/FormField';
import PaymentFields from 'payment-fields';
import { action, observable } from 'mobx';
import { observer } from 'mobx-react';
import { getColumnProps } from 'react-flexbox-grid';
import classnames from 'classnames';
import './field.scss';

@observer
export default class PaymentField extends React.Component {

    @action.bound
    onFocus() {
        this.wrapper._onFocus();
        this.errorMessage = '';
    }

    @action.bound
    onBlur({ isValid, isPotentiallyValid }) {
        this.isValid = isValid;
        this.wrapper._onBlur();
        this.errorMessage = isPotentiallyValid ? '' : this.props.errorMessage;
    }

    @observable isValid = false;
    @observable errorMessage = '';

    @action.bound onValidityChange({ isValid, isPotentiallyValid }) {
        this.isValid = isValid;
        this.errorMessage = isPotentiallyValid ? '' : this.props.errorMessage;
    }

    exposeError() {
        if (!this.isValid) {
            this.errorMessage = this.props.errorMessage;
        }
    }

    @action.bound
    setRef(f) { this.wrapper = f; }

    render() {
        const {
            label, className, ...cardFieldProps
        } = getColumnProps(this.props);
        return (
            <div className={classnames('payment-field form-field', className)}>
                <FieldWrapper
                    error={this.errorMessage}
                    label={label}
                    ref={this.setRef}
                >
                    <PaymentFields.Field
                        {...cardFieldProps}
                        onFocus={this.onFocus}
                        onBlur={this.onBlur}
                    />
                </FieldWrapper>
            </div>
        );
    }

}
