import React from 'react';
import { Row } from 'react-flexbox-grid';
import { isNil, forIn, get } from 'lodash';

import { observer }   from 'mobx-react';
import { action, observable, computed } from 'mobx';

import Button    from 'grommet/components/Button';
import Warning from 'lanes/components/warning-notification';
import Field from 'lanes/components/form-field';

import { WithValidatedFields, validEmail, nonBlank, validation } from 'lanes/lib/form-validation';
import Query from 'lanes/models/query';


@observer
class EditForm extends React.PureComponent {

    static propTypes = {
        query:      React.PropTypes.instanceOf(Query).isRequired,
        rowIndex:   React.PropTypes.number.isRequired,
        onComplete: React.PropTypes.func.isRequired,
        fields: React.PropTypes.shape({
            login: React.PropTypes.object,
            name:  React.PropTypes.object,
            password:  React.PropTypes.object,
            password_confirm: React.PropTypes.object,
        }).isRequired,
        formState: React.PropTypes.shape({
            touchd: React.PropTypes.bool,
            valid:  React.PropTypes.bool,
        }).isRequired,
        setDefaultValues: React.PropTypes.func.isRequired,
    }

    constructor(props) {
        super(props);
        this.user = this.props.query.results.modelForRow(this.props.rowIndex);
    }

    componentDidMount() {
        this.props.setDefaultValues(this.user.serialize());
    }
    @action.bound
    onSave() {
        forIn(this.props.fields, (field, name) => (this.user[name] = field.value));
        this.user.save().then(this.onSaved);
    }

    @action.bound
    onSaved(user) {
        if (user.errors) {
            this.errorMessage = user.lastServerMessage;
        } else {
            this.props.onComplete();
        }
    }

    @action.bound
    onCancel() {
        this.props.onComplete();
    }

    @observable
    errorMessage = ''


    @computed get isSavable() {
        return this.props.formState.valid && !this.user.syncInProgress;
    }


    render() {
        const {
            fields: { login, name, email, password, password_confirm },
        } = this.props;

        return (
            <div className="user-edit-form">
                <Warning message={this.errorMessage} />
                <Row middle='sm'>
                    <Field md={4} xs={6} name="login" field={login} />
                    <Field md={4} xs={6} name="name" field={name} />
                    <Field md={4} xs={6} name="email" field={email} />
                    <Field md={4} xs={6} type="password" name="password" field={password} />
                    <Field md={4} xs={6} type="password" name="password_confirm" field={password_confirm} />
                    <Col md={4} xs={6}>
                        <Row  middle="xs" around="xs">
                            <Button label="Cancel" onClick={this.onCancel} accent />
                            <Button
                                label="Save"
                                onClick={this.isSavable ? this.onSave : null}
                                primary
                            />
                        </Row>
                    </Col>
                </Row>
            </div>
        );
    }
}

export default WithValidatedFields({
    login: nonBlank,
    name:  nonBlank,
    email: validEmail,
    password: validation({
        alsoTest: ['password_confirm'],
        test: () => true,
    }),
    password_confirm: validation({
        message: 'must match password',
        test: (value, fields) => {
            const password = get(fields, 'password.value');
            if (isNil(password)) { return true; }
            return (password === value);
        },
    }),
}, EditForm, {
    desiredHeight: 300,
});
