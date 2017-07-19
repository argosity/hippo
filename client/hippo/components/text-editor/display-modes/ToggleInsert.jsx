import React from 'react'; // eslint-disable-line no-unused-vars
import AddIcon from 'grommet/components/icons/base/TableAdd';
import { connect } from 'react-redux';
import { insertMode } from 'ory-editor-core/lib/actions/display';
import { isInsertMode } from 'ory-editor-core/lib/selector/display';
import { createStructuredSelector } from 'reselect';
import Button from './Button';

const Inner = ({ isInsertMode: isinm, insertMode: inm }) => (
    <Button
        icon={<AddIcon />}
        label="Add"
        active={isinm}
        onClick={inm}
    />
);

const mapStateToProps = createStructuredSelector({ isInsertMode });
const mapDispatchToProps = { insertMode };

export default connect(mapStateToProps, mapDispatchToProps)(Inner);
