import React from 'react';
import PropTypes from 'prop-types';
import { Row, Col } from 'react-flexbox-grid';
import { isNil, forIn, get, pick, mapValues, keys, extend } from 'lodash';

import { observer }   from 'mobx-react';
import { action, observable, computed } from 'mobx';

import Box    from 'grommet/components/Box';
import Button from 'grommet/components/Button';
import Warning from 'hippo/components/warning-notification';

import Query from 'hippo/models/query';

import { Form, Field, FieldDefinitions, nonBlank, validEmail, booleanValue, field  } from 'hippo/components/form';

@observer
export default class EditForm extends React.PureComponent {

    static propTypes = {
        query:      PropTypes.instanceOf(Query).isRequired,
        rowIndex:   PropTypes.number.isRequired,
        onComplete: PropTypes.func.isRequired,
    }

    static desiredHeight = 300

    fields = new FieldDefinitions({
        is_admin: booleanValue,
        login: nonBlank,
        name:  nonBlank,
        email: validEmail,
        password: field,
    })

    constructor(props) {
        super(props);

        this.user = this.props.query.results.modelForRow(this.props.rowIndex);
    }

    componentDidMount() {
        this.fields.setFromModel(this.user);
    }

    @action.bound
    onSave() {
        this.fields.persistTo(this.user);
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
        const { fields } = this;
        return (
            <Form tag="div" className="user-edit-form" fields={fields}>
                <Warning message={this.errorMessage} />
                <Row middle='sm'>
                    <Field md={4} xs={6} name="login" />
                    <Field md={4} xs={6} name="name"  />
                    <Field md={4} xs={6} name="email" />
                    <Field md={4} xs={6} type="password" name="password" />
                    <Field md={4} xs={6} type="checkbox" name="is_admin" />
                    <Col md={4} xs={6}>
                        <Box justify="around" direction="row">
                            <Button label="Cancel" onClick={this.onCancel} accent />
                            <Button
                                label="Save"
                                onClick={fields.isValid ? this.onSave : null}
                                primary
                            />
                        </Box>
                    </Col>
                </Row>
            </Form>
        );
    }
}
