// @flow
import React from 'react'; // eslint-disable-line no-unused-vars
import getMuiTheme from 'material-ui/styles/getMuiTheme';
import MuiThemeProvider from 'material-ui/styles/MuiThemeProvider';
import type { ContentPluginProps } from 'ory-editor-core/lib/service/plugin/classes';
import Display from './Display';
import Form from './Form';

export type PropTypes = ContentPluginProps<{ src: string, caption: string }>

const Image = (props: PropTypes) => (
    <MuiThemeProvider muiTheme={getMuiTheme()}>
        {props.readOnly ? <Display {...props} /> : <Form {...props} />}
    </MuiThemeProvider>
);

export default Image;
