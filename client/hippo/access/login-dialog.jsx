import React from 'react';
import { observer } from 'mobx-react';
import { action } from 'mobx';
import { Box, Layer } from 'grommet';
import LoginForm from './login-form';
import User from '../user';

@observer
export default class LoginDialog extends React.Component {

    @action.bound
    attemptLogin({ username, password }) {
        User.attemptLogin(username, password);/* .then((session)=> {
                                                if session.isValid
                                                }); */
    }

    render() {
        if (User.isLoggedIn) { return null; }
        return (
            <Layer closer>
                <Box margin="medium">
                    <LoginForm
                        title="Please Login…"
                        onSubmit={this.attemptLogin}
                        usernameType="text"
                        secondaryText={User.lastServerMessage}
                    />
                </Box>
            </Layer>
        );
    }

}
