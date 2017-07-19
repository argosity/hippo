import React from 'react'; // eslint-disable-line no-unused-vars
import Header from 'grommet/components/Header';
import Provider from 'ory-editor-ui/lib/Provider';
import ToggleEdit from './ToggleEdit';
import ToggleInsert from './ToggleInsert';
import ToggleLayout from './ToggleLayout';
import TogglePreview from './TogglePreview';
import ToggleResize from './ToggleResize';
import SaveState from './SaveState';

const Inner = (props: any) => (
    <Provider {...props}>
        <Header
            wrap
            margin="small"
            justify="end"
            pad={{ horizontal: 'small' }}
        >
            <ToggleInsert />
            <ToggleEdit />
            <ToggleLayout />
            <ToggleResize />
            <TogglePreview />
            {props.children}
            <SaveState onSave={props.onSave} />
        </Header>
    </Provider>
);

export default Inner;
