import React from 'react';
import PropTypes from 'prop-types';
import { observer }   from 'mobx-react';
import { observable, action } from 'mobx';
import { Button } from 'grommet';
import Warning from '../../components/warning-notification';
import SaveButton from '../../components/save-button';
import Query from '../../models/query';
import { Cell } from '../../components/grid';
import { Form, Field, FormState, nonBlank, validEmail, booleanValue } from '../../components/form';

@observer
export default class EditForm extends React.Component {

    static propTypes = {
        query:      PropTypes.instanceOf(Query).isRequired,
        rowIndex:   PropTypes.number.isRequired,
        onComplete: PropTypes.func.isRequired,
    }

    static desiredHeight = 300

    @observable errorMessage;

    formState = new FormState();

    constructor(props) {
        super(props);
        this.user = this.props.query.results.modelForRow(this.props.rowIndex);
    }

    componentDidMount() {
        this.formState.setFromModel(this.user);
    }

    @action.bound
    onSave() {
        this.refs.form.persistTo(this.user);
        this.user.save().then(this.onSaved);
    }

    @action.bound
    onSaved(user) {
        if (user.errors) {
            this.errorMessage = user.errorMessage;
        } else {
            this.props.onComplete();
        }
    }

    @action.bound
    onCancel() {
        this.props.onComplete();
    }

    render() {
        return (
            <Form
                grid
                ref="form"
                model={this.user}
                className="user-edit-form"
            >
                <Warning message={this.errorMessage} />
                <Field phone={1} name="login" validate={nonBlank} />
                <Field phone={2} name="name" validate={nonBlank} />
                <Field phone={2} name="email" validate={validEmail} />
                <Field phone={1} type="password" name="password" />
                <Field phone={1} align="center" type="checkbox" name="is_admin" validate={booleanValue} />
                <Cell phone={3} center middle gap="small">
                    <Button label="Cancel" onClick={this.onCancel} accent />
                    <SaveButton
                        onClick={this.formState.isValid ? this.onSave : null}
                        model={this.user}
                    />
                </Cell>
            </Form>
        );
    }

}
