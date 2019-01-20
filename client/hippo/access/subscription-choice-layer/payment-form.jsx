import React from 'react';
import { each, every } from 'lodash';
import { action, observable, computed } from 'mobx';
import { observer } from 'mobx-react';
import PaymentFields from 'payment-fields';
import { Box, Button } from 'grommet';
import { CreditCard } from 'grommet-icons';
import NetworkActivityOverlay from '../../components/network-activity-overlay';
import CardField from '../../components/payments/field';
import WarningNotification from '../../components/warning-notification';

@observer
export default class PaymentForm extends React.Component {

    @observable isTokenizing = false;

    @observable getToken;

    @observable fields = {
        postalCode: false,
        cardNumber: false,
        expirationDate: false,
        cvv: false,
    }

    componentWillMount() {
        this.props.subscription.fetch();
    }

    @action.bound setFieldRef(ref) {
        if (ref) {
            this.fields[ref.props.type] = ref;
        }
    }

    @action.bound onSubscribe() {
        if (!every(this.fields, 'isValid')) {
            each(this.fields, f => f.exposeError());
            return;
        }
        this.subscribeToSubscription();
    }

    @action.bound onFormReady(ev) {
        this.getToken = ev.tokenize;
    }

    @action.bound subscribeToSubscription() {
        this.isTokenizing = true;
        const { subscription } = this.props;
        this.getToken().then(({ token: { nonce } }) => {
            subscription.nonce = nonce;
            return subscription.save().then(() => {
                this.isTokenizing = false;
                if (!subscription.errorMessage) {
                    this.props.onSuccess();
                }
            });
        }).catch(({ message }) => {
            subscription.errors = { base: message };
            this.isTokenizing = false;
        });
    }

    @computed get isBusy() {
        return !this.getToken || this.isTokenizing;
    }

    render() {
        const { subscription } = this.props;
        if (!subscription) { return <span />; }

        return (
            <PaymentFields
                className="payment-form"
                vendor="Braintree"
                onReady={this.onFormReady}
                ref={this.setPaymentRef}
                authorization={subscription.authorization}
                styles={{
                    base: {
                        color: '#3a3a3a',
                        'line-height': '40px',
                        'font-size': '16px',
                    },
                    focus: {
                        color: 'black',
                    },
                }}
            >
                <NetworkActivityOverlay
                    message={this.isTokenizing ? 'Subscribing…' : 'Initializing'}
                    visible={this.isBusy}
                    model={subscription}
                />
                <Box
                    margin="medium"
                    pad={{ between: 'small' }}
                >
                    <h4>
                        Card to bill for “{subscription.name}” plan
                        (${subscription.formattedPrice}/mo)
                    </h4>

                    <CardField
                        errorMessage="Invalid Card"
                        label="Card Number"
                        type="cardNumber"
                        placeholder="•••• •••• •••• ••••"
                        ref={this.setFieldRef}
                    />
                    <CardField
                        label="Expiration"
                        placeholder="MM / YY"
                        type="expirationDate"
                        errorMessage="Invalid Date"
                        ref={this.setFieldRef}
                    />
                    <CardField
                        label="CVV"
                        type="cvv"
                        errorMessage="Invalid"
                        ref={this.setFieldRef}
                    />
                    <CardField
                        label="Postal Code"
                        type="postalCode"
                        errorMessage="Invalid"
                        ref={this.setFieldRef}
                    />

                    <WarningNotification
                        flex margin="medium"
                        message={subscription.errorMessage}
                    />

                </Box>

                <Box
                    justify="end"
                    direction="row"
                    margin="medium"
                    gap="small"
                    pad={{ between: 'small' }}
                >
                    <Button label="Back" onClick={this.props.onCancel} />
                    <Button
                        onClick={this.isBusy ? null : this.onSubscribe}
                        primary icon={<CreditCard />}
                        label="Start Subscription" />
                </Box>
            </PaymentFields>
        );
    }

}
