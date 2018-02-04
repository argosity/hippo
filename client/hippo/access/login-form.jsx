import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { action } from 'mobx';
import { Heading, Box, Button } from 'grommet';
import Notification from '../components/notification';
import {
    Form, Field, FormState,
} from '../components/form';
import Logo from '../workspace/logo';

const CLASS_ROOT = 'login-form';

export default class LoginForm extends Component {

    formState = new FormState()


    @action.bound onSubmit() {
        this.props.onSubmit(this.formState.serialize());
    }

    render() {
        const {
            align, errors, forgotPassword,
            errorText,
        } = this.props;

        const errorsNode = errors.map((error, index) => {
            if (error) {
                let errorMessage;
                if (React.isValidElement(error)) {
                    errorMessage = error;
                } else {
                    errorMessage = <Notification message={error} />;
                }
                return (
                    <div key={index} className='error'>
                        {errorMessage}
                    </div>
                );
            }
            return undefined;
        });

        let errorTextNode;
        if (errorText) {
            errorTextNode = (
                <p align={align} margin="none">{errorText}</p>
            );
        }

        return (
            <Form
                tag="div"
                state={this.formState}
                pad="medium"
            >

                <Box align={align} align="start">
                    <Logo />
                    <Heading
                        level="2"
                        margin="small"
                        strong={true}
                    >Please Login…</Heading>
                    {errorTextNode}
                </Box>

                <Field name="username" autoFocus autoCorrect="off" autoCapitalize="none"/>

                <Field name="password" type="password" />

                {errorsNode}

                <Box
                    size="small" direction="column"
                    align="stretch"
                    margin={{ vertical: 'medium' }}
                    pad={{ vertical: 'none', between: 'medium' }}
                >
                    <Button
                        primary={true}
                        fill={false}
                        label="Log In"
                        onClick={this.onSubmit}
                    />
                    {forgotPassword}
                </Box>

            </Form>
        );
    }

}

LoginForm.propTypes = {
    align: PropTypes.oneOf(['start', 'center', 'end', 'stretch']),
    defaultValues: PropTypes.shape({
        username: PropTypes.string,
    }),
    errors: PropTypes.arrayOf(PropTypes.oneOfType([
        PropTypes.string,
        PropTypes.node,
    ])),
    forgotPassword: PropTypes.node,
    onSubmit: PropTypes.func.isRequired,
    errorText: PropTypes.string,
};

LoginForm.defaultProps = {
    align: 'center',
    defaultValues: {
        username: '',
    },
    errors: [],
};
