import React from 'react';
import PropTypes from 'prop-types';
import { Row, Col } from 'react-flexbox-grid';

import { observer }   from 'mobx-react';
import { action } from 'mobx';

import Box    from 'grommet/components/Box';
import Button from 'grommet/components/Button';
import Warning from 'hippo/components/warning-notification';

import Query from 'hippo/models/query';

import { Form, Field, FormState, nonBlank, validEmail, booleanValue, field  } from 'hippo/components/form';

@observer
export default class EditForm extends React.PureComponent {

    static propTypes = {
        query:      PropTypes.instanceOf(Query).isRequired,
        rowIndex:   PropTypes.number.isRequired,
        onComplete: PropTypes.func.isRequired,
    }

    static desiredHeight = 300

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
            this.errorMessage = user.lastServerMessage;
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
                        <Box direction="row">
                            <Button label="Cancel" onClick={this.onCancel} accent />
                            <Button
                                label="Save"
                                onClick={this.formState.isValid ? this.onSave : null}
                                primary
                            />
                        </Box>
                    </Col>
                </Row>
            </Form>
        );
    }
}
