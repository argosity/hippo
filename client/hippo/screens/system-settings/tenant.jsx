import React from 'react';
import { observer } from 'mobx-react';
import { observable } from 'mobx';
import { Row } from 'react-flexbox-grid';
import Heading from 'grommet/components/Heading';
import Box from 'grommet/components/Box';
import { Form, Field, FormState, nonBlank } from 'hippo/components/form';

import Notification from 'grommet/components/Notification';
import Layer from 'grommet/components/Layer';
import Paragraph from 'grommet/components/Paragraph';
import Anchor from 'grommet/components/Anchor';
import LinkIcon from 'grommet/components/icons/base/Link';

import Tenant from '../../models/tenant';
import Config from '../../config';

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
                <Anchor icon={<LinkIcon />} label={Tenant.current.domain} href={`https://${Tenant.current.domain}`} primary={true} />
            </Box>
        </Layer>
    );
}

@observer
export default class TenantConfig extends React.Component {

    formState = new FormState()

    @observable slugChangedFrom;

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

    componentWillMount() {
        this.formState.setFromModel(Tenant.current);
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
                {this.renderIdChangeWarning()}
            </Form>
        );
    }

}
