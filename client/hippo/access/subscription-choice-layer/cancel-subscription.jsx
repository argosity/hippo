import React from 'react';
import { defer } from 'lodash';
import { action, observable } from 'mobx';
import { observer } from 'mobx-react';
import Button from 'grommet/components/Button';
import ClearIcon from 'grommet/components/icons/base/Clear';
import CloseIcon from 'grommet/components/icons/base/Close';
import Box from 'grommet/components/Box';
import Config from '../../config';
import User from '../../user';
import Tenant from '../../models/tenant';
import NetworkActivityOverlay from '../../components/network-activity-overlay';

@observer
export default class CancelSubscription extends React.Component {

    @observable isCanceled = false;
    @observable isCanceling = false;

    @action.bound cancelSubscription() {
        this.isCanceling = true;
        Tenant.current.subscription.destroy().then(() => {
            this.isCanceling = false;
            this.isCanceled = true;
        });
    }

    @action.bound onCancelComplete() {
        this.props.onCancel();
        User.logout();
        defer(() => { Tenant.current.subscription_id = null; });
    }

    renderCanceled() {
        window.c = Config;
        return (
            <Box className="subscription-canceled">
                <h3>Subscription canceled</h3>
                <h5>
                    We're sorry to see you go!  If you'd ever like to contact us and
                    share any feedback we can be reached
                    at <a href={`mailto:${Config.support_email}`}>{Config.support_email}</a>
                </h5>
                <p>
                    Your subscription to {Config.product_name} has been canceled.
                    You can regain access to your account information by
                    logging in and choosing a new plan.
                </p>
                <Box align="end">
                    <Button
                        critical
                        icon={<ClearIcon />}
                        onClick={this.onCancelComplete}
                        label="Logout"
                    />
                </Box>
            </Box>
        );
    }

    render() {
        if (this.isCanceled) { return this.renderCanceled(); }

        return (
            <Box
                className="subscription-cancel"
                justify="around"
                size="large"
            >
                <NetworkActivityOverlay
                    message="Canceling…"
                    model={Tenant.current.subscription}
                    visible={this.isCanceling}
                />
                <h3>Cancel subscription?</h3>
                <h5>
                    We're sorry to see you go!  If you'd ever like to contact us and
                    share any feedback we can be reached
                    at <a href={`mailto:${Config.support_email}`}>{Config.support_email}</a>
                </h5>
                <p>
                    Canceling your subscription will immediately revoke
                    your access to {Config.product_name}, and will suspend
                    all of your current listings.
                </p>
                <p>
                    Your data will remain intact and can be accessed once you
                    re-subscribe to a plan.
                </p>
                <Box
                    justify="between"
                    direction="row"
                    pad={{ between: 'small' }}
                >
                    <Button
                        critical
                        icon={<ClearIcon />}
                        onClick={this.cancelSubscription}
                        label="Cancel Subscription"
                    />
                    <Button
                        label="Close"
                        icon={<CloseIcon />}
                        onClick={this.props.onCancel}
                    />
                </Box>
            </Box>
        );
    }

}
