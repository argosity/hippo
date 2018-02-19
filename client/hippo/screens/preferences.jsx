import React from 'react';
import PropTypes from 'prop-types';
import { observer } from 'mobx-react';
import { action } from 'mobx';
import Screen from '../components/screen';
import { Toolbar, SaveButton } from '../components/toolbar';
import {
    Form, Field, FormState, nonBlank, validEmail, FieldsLayout, Heading,
} from '../components/form';
import User from '../user';

@observer
export default class Preferences extends React.Component {

    static propTypes = {
        screen: PropTypes.instanceOf(Screen.Instance).isRequired,
    }

    formState = new FormState()

    componentWillMount() {
        User.fetch();
        this.formState.setFromModel(User);
    }

    @action.bound onSave() {
        if (this.formState.isValid) {
            this.formState.persistTo(User)
                .then(() => User.save())
                .then(() => this.formState.setFromModel(User));
        } else {
            this.formState.exposeErrors();
        }
    }

    render() {
        return (
            <Form screen={this.props.screen} state={this.formState}>
                <Toolbar>
                    <SaveButton
                        model={User}
                        onClick={this.onSave}
                    />
                </Toolbar>
                <Heading>Account information</Heading>
                <FieldsLayout>
                    <Field cellWidth={2} name="login" validate={nonBlank} />
                    <Field name="name" validate={nonBlank} />
                    <Field name="email" validate={validEmail} />
                    <Field cellWidth={2} name="password" type="password" />
                </FieldsLayout>
            </Form>
        );
    }

}
