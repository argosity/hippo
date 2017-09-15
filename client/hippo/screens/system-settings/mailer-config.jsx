import React from 'react';
import { action } from 'mobx';
import { observer } from 'mobx-react';
import { Row } from 'react-flexbox-grid';
import Heading from 'grommet/components/Heading';

import { Form, Field, FormState, nonBlank, validEmail  } from 'hippo/components/form';

@observer
export default class MailerConfig extends React.PureComponent {

    formState = new FormState()

    @action.bound
    onSave() {
        if (!this.props.settings.smtp) { this.props.settings.smtp = {}; }
        this.formState.persistTo(this.props.settings.smtp);
    }

    componentWillMount() {
        this.props.registerForSave(this);
        this.formState.set(this.props.settings.smtp || {});
    }

    componentWillReceiveProps(nextProps) {
        this.formState.set(nextProps.settings.smtp || {});
    }


    render() {
        return (
            <div className="section">
                <Heading tag="h3">Email settings</Heading>
                <Form state={this.formState}>
                    <Row className="section">
                        <Field xs={6} name="from_email" label="From Email" validate={validEmail} />
                        <Field xs={6} name="from_name" label="From Name" validate={nonBlank} />
                    </Row>
                </Form>
            </div>
        );
    }

}
