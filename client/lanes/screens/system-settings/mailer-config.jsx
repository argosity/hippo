import React from 'react';
import { action } from 'mobx';
import { observer } from 'mobx-react';
import { Row } from 'react-flexbox-grid';
import Heading from 'grommet/components/Heading';

import { Form, Field, FieldDefinitions, nonBlank, validEmail  } from 'lanes/components/form';

@observer
export default class MailerConfig extends React.PureComponent {

    fields = new FieldDefinitions({
        user_name:  nonBlank,
        password:   nonBlank,
        address:    nonBlank,
        from_email: validEmail,
        from_name:  nonBlank,
    })

    @action.bound
    onSave() {
        if (!this.props.settings.smtp) { this.props.settings.smtp = {}; }
        this.fields.persistTo(this.props.settings.smtp);
    }

    componentWillMount() {
        this.props.registerForSave(this);
        this.fields.set(this.props.settings.smtp || {});
    }

    componentWillReceiveProps(nextProps) {
        this.fields.set(nextProps.settings.smtp || {});
    }


    render() {
        return (
            <div className="section">
                <Heading tag="h3">Email settings</Heading>
                <Form fields={this.fields}>
                    <Row className="section">
                        <Field md={4} xs={6} name="user_name" />
                        <Field md={4} xs={6} name="password" type="password" />
                        <Field md={4} xs={6} name="address" label="Server Address" />
                        <Field md={4} xs={6} name="from_email" label="From Email" />
                        <Field md={4} xs={6} name="from_name" label="From Name" />
                    </Row>
                </Form>
            </div>
        );
    }

}
