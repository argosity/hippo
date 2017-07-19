// @flow
import React from 'react'; // eslint-disable-line no-unused-vars
import { connect } from 'react-redux';
import { editMode } from 'ory-editor-core/lib/actions/display';
import { isEditMode } from 'ory-editor-core/lib/selector/display';
import { createStructuredSelector } from 'reselect';
import EditIcon from 'grommet/components/icons/base/Edit';
import Button from './Button';

const Inner = ({ isEditMode: isedm, editMode: edm }) => (
    <Button
        icon={<EditIcon />}
        label="Edit"
        active={isedm}
        onClick={edm}
    />
);

const mapStateToProps = createStructuredSelector({ isEditMode });
const mapDispatchToProps = { editMode };

export default connect(mapStateToProps, mapDispatchToProps)(Inner);
