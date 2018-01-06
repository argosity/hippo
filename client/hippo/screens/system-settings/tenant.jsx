import React from 'react';
import { observer } from 'mobx-react';
import { observable, action } from 'mobx';
import { Row } from 'react-flexbox-grid';
import Heading from 'grommet/components/Heading';
import Box from 'grommet/components/Box';
import { Form, Field, FormState, nonBlank } from 'hippo/components/form';
import Notification from 'hippo/components/notification';
import Layer from 'grommet/components/Layer';
import Paragraph from 'grommet/components/Paragraph';
import Anchor from 'grommet/components/Anchor';
import Button from 'grommet/components/Button';
import { Link, Clear, UserAdmin } from 'grommet-icons';
import Tenant from '../../models/tenant';
import Config from '../../config';
import SubscriptionChoiceLayer from '../../access/subscription-choice-layer';

function onTenantSlugChangeClose() { }

function TenantSlugChange({ oldSlug }) {
    if (!oldSlug) { return null; }
    return (
        <Layer onClose={onTenantSlugChangeClose}>
            <Box pad="medium">
                <Heading tag="h3">Your account identifier has changed!</Heading>
                <Paragraph size='large'>
                    You will need to login to your account from the updated address at:
                </Paragraph>
                <Anchor icon={<Link />} label={Tenant.current.domain} href={`https://${Tenant.current.domain}`} primary={true} />
            </Box>
        </Layer>
    );
}

@observer
export default class TenantConfig extends React.Component {

    formState = new FormState()

    @observable slugChangedFrom;
    @observable isCanceling;
    @observable showSubscriptionChoice = false;

    onSave() {
        const originalSlug = Tenant.current.slug;
        this.formState
            .persistTo(Tenant.current)
            .then(() => Tenant.current.save())
            .then(() => {
                if (Tenant.current.slug !== originalSlug) {
                    this.slugChangedFrom = originalSlug;
                }
            });
    }

    @action.bound onSubscriptionChange() {
        this.showSubscriptionChoice = {
            isCanceling: false,
        };
    }

    @action.bound onSubscriptionCancel() {
        this.showSubscriptionChoice = {
            isCanceling: true,
        };
    }

    @action.bound hideSubscriptionChoice() {
        this.showSubscriptionChoice = false;
    }

    componentWillMount() {
        this.formState.setFromModel(Tenant.current);
    }

    renderSubscriptionChoice() {
        if (!this.showSubscriptionChoice) { return null; }
        return (
            <SubscriptionChoiceLayer
                displayCancel
                {...this.showSubscriptionChoice}
                onCancel={this.hideSubscriptionChoice}
                onChoice={this.hideSubscriptionChoice} />
        );
    }

    renderIdChangeWarning() {
        const slug = this.formState.get('slug.value');
        if (!Tenant.current.slug || slug === Tenant.current.slug) {
            return null;
        }
        return (
            <Notification
                size="small" status="warning"
                message={`Warning:  Changing the identifier will also change where you login at. The updated address will be: ${slug}.${Config.website_domain}`}
            />
        );
    }

    render() {
        return (
            <Form tag="div" className="tenant-edit-form" state={this.formState}>
                {this.renderSubscriptionChoice()}
                <TenantSlugChange oldSlug={this.slugChangedFrom} />
                <Heading tag="h3">Account</Heading>
                <Row>
                    <Field
                        xs={6} name="slug"
                        label="Identifier"
                        validate={nonBlank}
                    />
                    <Field xs={6} name="name" validate={nonBlank} />
                </Row>
                <Row>
                    <Field
                        xs={12} type="label"
                        label="Subscription"
                        name="subscription_name"
                        value={
                            <Box direction="row" justify="between">
                                <Button
                                    plain label={Tenant.current.subscription.nameAndCost}
                                    icon={<UserAdmin />}
                                    onClick={this.onSubscriptionChange}
                                />
                                <Button
                                    plain label="Cancel"
                                    icon={<Clear />}
                                    onClick={this.onSubscriptionCancel}
                                />
                            </Box>
                        }
                    />
                </Row>
                {this.renderIdChangeWarning()}
            </Form>
        );
    }

}
