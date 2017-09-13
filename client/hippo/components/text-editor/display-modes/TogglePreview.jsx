import React from 'react'; // eslint-disable-line no-unused-vars
import Devices from 'material-ui/svg-icons/device/devices';
import { connect } from 'react-redux';
import { previewMode } from 'ory-editor-core/lib/actions/display';
import { isPreviewMode } from 'ory-editor-core/lib/selector/display';
import { createStructuredSelector } from 'reselect';
import Button from './Button';

const Inner = ({ className, isPreviewMode: ispvm, previewMode: pvm }) => (
    <Button
        className={className}
        icon={<Devices />}
        label="Preview"
        active={ispvm}
        onClick={pvm}
    />
);

const mapStateToProps = createStructuredSelector({ isPreviewMode });
const mapDispatchToProps = { previewMode };

export default connect(mapStateToProps, mapDispatchToProps)(Inner);
