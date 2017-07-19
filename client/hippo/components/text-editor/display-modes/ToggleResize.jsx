import React from 'react'; // eslint-disable-line no-unused-vars
import ResizeIcon from 'grommet/components/icons/base/Pan';
import { connect } from 'react-redux';
import { resizeMode } from 'ory-editor-core/lib/actions/display';
import { isResizeMode } from 'ory-editor-core/lib/selector/display';
import { createStructuredSelector } from 'reselect';
import Button from './Button';

const Inner = ({ isResizeMode: isrsm, resizeMode: rsm }) => (
    <Button
        icon={<ResizeIcon />}
        label="Resize"
        active={isrsm}
        onClick={rsm}
    />
);

const mapStateToProps = createStructuredSelector({ isResizeMode });
const mapDispatchToProps = { resizeMode };

export default connect(mapStateToProps, mapDispatchToProps)(Inner);
