import React from 'react';
import PropTypes from 'prop-types';
import { Row, Col } from 'react-flexbox-grid';

import { observer }   from 'mobx-react';
import { observable, action } from 'mobx';

import Box    from 'grommet/components/Box';
import Button from 'grommet/components/Button';
import Warning from '../../components/warning-notification';
import SaveButton from '../../components/save-button';
import Query from '../../models/query';

import { Form, Field, FormState, nonBlank, validEmail, booleanValue } from '../../components/form';

@observer
export default class EditForm extends React.PureComponent {
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
                tag="div"
                ref="form"
                model={this.user}
                className="user-edit-form"
            >
                <Warning message={this.errorMessage} />
                <Row middle='sm'>
                    <Field md={4} xs={6} name="login" validate={nonBlank} />
                    <Field md={4} xs={6} name="name" validate={nonBlank} />
                    <Field md={4} xs={6} name="email" validate={validEmail} />
                    <Field md={4} xs={6} type="password" name="password" />
                    <Field md={4} xs={6} type="checkbox" name="is_admin" validate={booleanValue} />
                    <Col md={4} xs={6}>
                        <Box direction="row" justify="between">
                            <Button label="Cancel" onClick={this.onCancel} accent />
                            <SaveButton
                                onClick={this.formState.isValid ? this.onSave : null}
                                model={this.user}
                            />
                        </Box>
                    </Col>
                </Row>
            </Form>
        );
    }
}
