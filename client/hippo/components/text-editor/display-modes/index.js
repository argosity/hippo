import React from 'react'; // eslint-disable-line no-unused-vars
import Header from 'grommet/components/Header';
import Provider from 'ory-editor-ui/lib/Provider';
import ToggleEdit from './ToggleEdit';
import ToggleInsert from './ToggleInsert';
import ToggleLayout from './ToggleLayout';
import TogglePreview from './TogglePreview';
import ToggleResize from './ToggleResize';


const Inner = (props: any) => (
    <Provider {...props}>
        <Header
            wrap

            margin="small"
            justify="end"
            pad={{ horizontal: 'small' }}
        >
            <ToggleInsert className="insert" />
            <ToggleEdit className="edit" />
            <ToggleLayout className="layout" />
            <ToggleResize className="resize" />
            <TogglePreview className="preview" />
            {props.children}
        </Header>
    </Provider>
);

export default Inner;
