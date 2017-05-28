import React from 'react';
import PropTypes from 'prop-types';
import { observer } from 'mobx-react';
import { Row } from 'react-flexbox-grid';
import Heading from 'grommet/components/Heading';
import { Form, Field, FormState, nonBlank } from 'hippo/components/form';
import Tenant from '../../models/tenant';
import CircleInformationIcon from 'grommet/components/icons/base/CircleInformation';
import ToolTip from '../../components/tool-tip';


@observer
export default class TenantConfig extends React.PureComponent {

    formState = new FormState()

    onSave() {
        this.formState.persistTo(Tenant.current)
            .then(() => Tenant.current.save());
    }

    componentWillMount() {
        this.formState.setFromModel(Tenant.current);
    }
    onTipClose() {

    }
    render() {
        return (
            <Form tag="div" className="tenant-edit-form" state={this.formState}>
                <Heading tag="h3">Account</Heading>
                <Row>
                    <Field md={4} xs={6} name="slug" label="Identifier" validate={nonBlank} />
                    <Field md={4} xs={6} name="name" validate={nonBlank} />
                </Row>
            </Form>
        );
    }
}
