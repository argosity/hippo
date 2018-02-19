import React from 'react';
import PaymentFields from 'payment-fields';
import { action, observable } from 'mobx';
import { observer } from 'mobx-react';
import styled from 'styled-components';
import { getColumnProps } from 'react-flexbox-grid';
import classnames from 'classnames';
import { FieldWrapper } from '../form';

const PaymentFieldWrapper = styled.div`
    padding-bottom: 0;
    .payment-field {
        height: 40px;
    }
    .hosted-card-field {
        height: 100%;
        border: 0;
    }
    .labels {
        padding-left: 0;
    }
`;

@observer
export default class PaymentField extends React.Component {

    @action.bound
    onFocus() {
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
            <PaymentFieldWrapper className={classnames('payment-field form-field', className)}>
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
            </PaymentFieldWrapper>
        );
    }

}
