import React from 'react';
import { action } from 'mobx';
import { observer } from 'mobx-react';
import { Heading, FieldsLayout, Form, Field, FormState, nonBlank, validEmail  } from 'hippo/components/form';

@observer
export default class MailerConfig extends React.Component {

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
                <Heading>Email settings</Heading>
                <Form state={this.formState}>
                    <FieldsLayout>
                        <Field name="from_email" label="From Email" validate={validEmail} />
                        <Field name="from_name" label="From Name" validate={nonBlank} />
                    </FieldsLayout>
                </Form>
            </div>
        );
    }

}
