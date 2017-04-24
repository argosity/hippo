import React from 'react';

import { observer } from 'mobx-react';
import { mapValues, pick, keys, isEmpty } from 'lodash';
import { Row } from 'react-flexbox-grid';
import Heading from 'grommet/components/Heading';
import { addFormFieldValidations, stringValue, validEmail } from 'lanes/lib/forms';
import Field from 'lanes/components/form-field';

@observer
class MailerConfig extends React.PureComponent {

    static formFields = {
        user_name:  stringValue,
        password:   stringValue,
        address:    stringValue,
        from_email: validEmail,
        from_name:  stringValue,
    }

    onSave() {
        this.props.settings.smtp = mapValues(this.props.fields, 'value');
    }

    componentWillMount() {
        this.props.registerForSave(this);
        this.setDefaults(this.props);
    }

    componentWillReceiveProps(nextProps) {
        this.setDefaults(nextProps);
    }

    setDefaults(props) {
        const config = pick(props.settings.smtp || {}, keys(this.constructor.formFields));
        if (!isEmpty(config)) {
            this.props.setDefaultValues(config);
        }
    }

    render() {
        const { fields } = this.props;

        return (
            <div className="section">
                <Heading tag="h3">Email settings</Heading>
                <Row className="section">
                    <Field md={4} xs={6} name="user_name" fields={fields} />
                    <Field md={4} xs={6} name="password" type="password" fields={fields} />
                    <Field md={4} xs={6} name="address" label="Server Address" fields={fields} />
                    <Field md={4} xs={6} name="from_email" label="From Email" fields={fields} />
                    <Field md={4} xs={6} name="from_name" label="From Name" fields={fields} />
                </Row>
            </div>
        );
    }

}

export default addFormFieldValidations(MailerConfig);
