import React from 'react';
import PropTypes from 'prop-types';
import { observer } from 'mobx-react';
import { action } from 'mobx';
import { Row } from 'react-flexbox-grid';
import Screen from '../components/screen';
import { Toolbar, SaveButton } from '../components/toolbar';
import {
    Form, Field, FormState, nonBlank, validEmail,
} from '../components/form';
import User from '../user';

@observer
export default class Preferences extends React.PureComponent {

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
                <h4>Account information:</h4>
                <Row>
                    <Field xs={6} name="login" validate={nonBlank} />
                    <Field xs={6} name="name" validate={nonBlank} />
                    <Field sm={6} xs={12} name="email" validate={validEmail} />
                    <Field sm={6} xs={12} name="password" type="password" />
                </Row>
            </Form>
        );
    }

}
