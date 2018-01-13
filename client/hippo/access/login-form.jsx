import React, { Component } from 'react';
import PropTypes from 'prop-types';
import classnames from 'classnames';
import { Box, Button } from 'grommet';

const CLASS_ROOT = 'login-form';

export default class LoginForm extends Component {

    constructor(props, context) {
        super(props, context);

        this._onSubmit = this._onSubmit.bind(this);
        this._onUsernameChange = this._onUsernameChange.bind(this);
        this._onPasswordChange = this._onPasswordChange.bind(this);
        this._onChange = this._onChange.bind(this);

        this.state = {
            timestamp: new Date().getTime(),
            password: '',
            username: '',
        };
    }

    componentDidMount() {
        if (this.usernameRef) {
            this.usernameRef.focus();
        }
    }

    _onChange(args) {
        const { onChange } = this.props;

        if (onChange) {
            onChange(args);
        }
    }

    _onUsernameChange(event) {
        const username = event.target.value;
        this.setState({ username });
        this._onChange({ event, username });
    }

    _onPasswordChange(event) {
        const password = event.target.value;
        this.setState({ password });
        this._onChange({ event, password });
    }

    _onSubmit(event) {
        event.preventDefault();
        const { onSubmit } = this.props;
        let { username } = this.state;
        const { password } = this.state;
        username = username.trim();

        if (onSubmit) {
            onSubmit({ username, password });
        }
    }

    render() {
        const {
            align, errors, forgotPassword,
            logo, onSubmit, secondaryText, title, usernameType,
        } = this.props;
        const { timestamp } = this.state;

        const classes = classnames(CLASS_ROOT, this.props.className);
        const center = !align || 'stretch' === align || 'center' === align;

        const errorsNode = errors.map((error, index) => {
            if (error) {
                let errorMessage;
                if (React.isValidElement(error)) {
                    errorMessage = error;
                } else {
                    errorMessage = <FormattedMessage id={error} defaultMessage={error} />;
                }
                return (
                    <div key={index} className='error'>
                        {errorMessage}
                    </div>
                );
            }
            return undefined;
        });

        let titleNode;
        if (title) {
            titleNode = <Heading strong={true}>{title}</Heading>;
        }

        let secondaryTextNode;
        if (secondaryText) {
            secondaryTextNode = (
                <Paragraph align={align} margin="none">{secondaryText}</Paragraph>
            );
        }

        const username = 'email' === usernameType ? (
            <FormattedMessage id="Email" defaultMessage="Email" />
        ) : (
            <FormattedMessage id="Username" defaultMessage="Username" />
        );

        const password = (
            <FormattedMessage id="Password" defaultMessage="Password" />
        );
        const login = <FormattedMessage id="Log In" defaultMessage="Log In" />;

        const usernameId = `grommetux-username_${timestamp}`;
        const passwordId = `grommetux-password_${timestamp}`;

        return (
            <Form className={classes} pad="medium" onSubmit={this._onSubmit}>
                <Box align={align}>
                    {logo}
                    {titleNode}
                    {secondaryTextNode}
                </Box>
                <fieldset>
                    <FormField htmlFor={usernameId} label={username}>
                        <input
                            id={usernameId}
                            type={usernameType}
                            ref={(ref) => { this.usernameRef = ref; }}
                            value={this.state.username}
                            onChange={this._onUsernameChange}
                        />
                    </FormField>
                    <FormField htmlFor={passwordId} label={password}>
                        <input
                            id={passwordId}
                            type="password"
                            value={this.state.password}
                            onChange={this._onPasswordChange}
                        />
                    </FormField>
                    {errorsNode}
                </fieldset>
                <Footer
                    size="small" direction="column"
                    align={center ? 'stretch' : 'start'}
                    pad={{ vertical: 'none', between: 'medium' }}
                >
                    <Button
                        primary={true} fill={center}
                        type={onSubmit ? 'submit' : 'button'}
                        label={login}
                        onClick={onSubmit ? this._onSubmit : undefined}
                    />
                    {forgotPassword}
                </Footer>
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
    logo: PropTypes.node,
    onSubmit: PropTypes.func,
    onChange: PropTypes.func,
    secondaryText: PropTypes.string,
    title: PropTypes.string,
    usernameType: PropTypes.string,
};

LoginForm.defaultProps = {
    align: 'center',
    defaultValues: {
        username: '',
    },
    errors: [],
    usernameType: 'email',
};
