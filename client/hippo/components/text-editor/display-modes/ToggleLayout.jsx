import React from 'react'; // eslint-disable-line no-unused-vars
import GridIcon from 'grommet/components/icons/base/Grid';
import { connect } from 'react-redux';
import { layoutMode } from 'ory-editor-core/lib/actions/display';
import { isLayoutMode } from 'ory-editor-core/lib/selector/display';
import { createStructuredSelector } from 'reselect';
import Button from './Button';

const Inner = ({ isLayoutMode: islm, layoutMode: lm }) => (
    <Button
        icon={<GridIcon />}
        label="Layout"
        active={islm}
        onClick={lm}
    />
);

const mapStateToProps = createStructuredSelector({ isLayoutMode });
const mapDispatchToProps = { layoutMode };

export default connect(mapStateToProps, mapDispatchToProps)(Inner);
