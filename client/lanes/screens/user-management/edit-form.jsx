import React from 'react';
import PropTypes from 'prop-types';
import { Row, Col } from 'react-flexbox-grid';
import { isNil, forIn, get, pick, mapValues, keys, extend } from 'lodash';

import { observer }   from 'mobx-react';
import { action, observable, computed } from 'mobx';

import Button    from 'grommet/components/Button';
import Warning from 'lanes/components/warning-notification';
import Field from 'lanes/components/form-field';

import { addFormFieldValidations, validEmail, nonBlank, validation, booleanValue, } from 'lanes/lib/forms';
import Query from 'lanes/models/query';


@observer
class EditForm extends React.PureComponent {

    static propTypes = {
        query:      PropTypes.instanceOf(Query).isRequired,
        rowIndex:   PropTypes.number.isRequired,
        onComplete: PropTypes.func.isRequired,
        fields: PropTypes.shape({
            login: PropTypes.object,
            name:  PropTypes.object,
            password:  PropTypes.object,
            password_confirm: PropTypes.object,
        }).isRequired,
        formState: PropTypes.shape({
            touchd: PropTypes.bool,
            valid:  PropTypes.bool,
        }).isRequired,
        setDefaultValues: PropTypes.func.isRequired,
    }

    static desiredHeight = 400

    static formFields = {
        is_admin: booleanValue,
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
                if (!password) { return true; }
                return (password === value);
            },
        }),
    }

    constructor(props) {
        super(props);

        this.user = this.props.query.results.modelForRow(this.props.rowIndex);
    }

    componentDidMount() {
        this.props.setDefaultValues(this.user.toJSON());
    }

    @action.bound
    onSave() {
        this.user.set(
            pick(mapValues(this.props.fields, 'value'), keys(this.constructor.formFields)),
        );
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
        const { fields } = this.props;

        return (
            <div className="user-edit-form">
                <Warning message={this.errorMessage} />
                <Row middle='sm'>
                    <Field md={4} xs={6} name="login" fields={fields} />
                    <Field md={4} xs={6} name="name" fields={fields} />
                    <Field md={4} xs={6} name="email" fields={fields} />
                    <Field md={4} xs={6} type="password" name="password" fields={fields} />
                    <Field md={4} xs={6} type="password" name="password_confirm" fields={fields} />
                    <Field md={4} xs={6} type="checkbox" name="is_admin" fields={fields} />
                    <Col md={4} xs={6}>
                        <Row middle="xs" around="xs">
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

export default addFormFieldValidations(EditForm, 'desiredHeight');
