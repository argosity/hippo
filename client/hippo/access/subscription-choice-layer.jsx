import React from 'react';
import { action, observable, computed } from 'mobx';
import { observer } from 'mobx-react';
import { sortBy }  from 'lodash';
import SwipeableViews from 'react-swipeable-views';
import { Box, Button, Layer } from 'grommet';
import { Star, Next, Close } from 'grommet-icons';
import styled from 'styled-components';
import Tenant from '../models/tenant';
import Subscription from '../models/subscription';
import PaymentForm from './subscription-choice-layer/payment-form';
import './subscription-choice-layer/subscription-choice.scss';

const SubscriptionChoices = styled.div`

    padding:  ${props => props.theme.global.edgeSize.small};

    .subscriptions-listing {
        min-height: 350px;
        polyline {
            transition: all 0.2s;
        }
        .subscription {
            cursor: pointer;
            &:hover {
                    polyline {
                    stroke-width: 3px;
                    stroke: black;
                }
            }
        }
    }

    .payment-fields-wrapper {
        min-height: 400px;
        position: relative;
        display: flex;
        flex-direction: column;
    }

    .grommetux-control-icon-next {
        margin-left: 1rem;
    }

`;

@observer
export default class SubscriptionChoiceLayer extends React.Component {

    @observable subscriptionId = Tenant.current.subscription_id;
    @observable displayIndex = 0;
    @observable showSubscription = false;
    @observable subscription;

    @action.bound onSubscriptionSelect(ev) {
        this.subscriptionId = ev.target.id;
    }

    @computed get sortedSubscriptions() {
        return sortBy(Subscription.all, pl => parseFloat(pl.price));
    }

    @action.bound showCCForm(subscription) {
        this.displayIndex = 1;
        this.subscription = subscription;
    }

    @action.bound goToSubscriptions() {
        this.displayIndex = 0;
        this.subscription = null;
    }

    @action.bound onPaymentSuccess() {
        this.displayIndex = 2;
    }

    @action.bound setSubscriptionOnTenant() {
        Tenant.current.subscription_id = this.subscription.id;
        if (this.props.onCancel) { this.props.onCancel(); }
    }

    renderSubscriptionChangeSuccess() {
        if (this.displayIndex !== 2) { return <span />; }
        const { subscription } = this;
        return (
            <Box
                className="success"
                margin="large"
            >
                <h4>You've selected the “{subscription.name}” subscription</h4>
                <p>
                    You can cancel the subscription or select a different
                    one at any time from “System Settings”.
                </p>
                <Button
                    label="Got it"
                    onClick={this.setSubscriptionOnTenant}
                />
            </Box>
        );
    }

    renderCardFields() {
        if (this.displayIndex !== 1) { return <span />; }
        const { subscription } = this;
        return (
            <PaymentForm
                subscription={subscription}
                onCancel={this.goToSubscriptions}
                onSuccess={this.onPaymentSuccess}
            />
        );
    }

    @action.bound renderSubscriptionChoice(subscription) {
        const isCurrent = (Tenant.current.subscription === subscription);
        return (
            <Box
                key={subscription.id}
                className="subscription"
                pad="medium"
                onClick={() => this.showCCForm(subscription)}

            >
                <Box
                    direction="row"
                    align="center"
                >
                    <Box flex>
                        <Box direction="row" justify="between">
                            <span>
                                {subscription.name}
                                {isCurrent && <Star colorIndex="brand" size="small" />}
                            </span>

                            <span className="price">
                                $ {subscription.formattedPrice}/month
                            </span>
                        </Box>
                        <span>{subscription.description}</span>
                    </Box>
                    <Next className="select"/>
                </Box>
            </Box>
        );
    }

    renderCloseButton() {
        if (!this.props.onCancel) { return null; }

        return (
            <Box margin={{ bottom: 'medium' }}  align="end">
                <Button
                    label="Close"
                    icon={<Close />}
                    onClick={this.props.onCancel}
                />
            </Box>
        );
    }

    renderSubscriptionListing() {
        if (this.props.isCanceling) {
            return <CancelSubscription onCancel={this.props.onCancel} />;
        }

        return (
            <Box
                className="subscriptions-listing"
                justify="around"
            >
                <h3>Choose subscription</h3>
                {this.sortedSubscriptions.map(this.renderSubscriptionChoice)}
                {this.renderCloseButton()}
            </Box>
        );
    }

    render() {
        return (
            <Layer
                className="subscription-choice-layer"
                closer={!!this.props.onCancel}
                onClose={this.props.onCancel}
            >
                <SubscriptionChoices>
                    <SwipeableViews
                        disabled index={this.displayIndex}
                    >
                        {this.renderSubscriptionListing()}
                        {this.renderCardFields()}
                        {this.renderSubscriptionChangeSuccess()}
                    </SwipeableViews>
                </SubscriptionChoices>
            </Layer>
        );
    }

}
