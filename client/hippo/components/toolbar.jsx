import React from 'react'; // eslint-disable-line no-unused-vars
import Header from 'grommet/components/Header';

export SaveButton from './save-button';

export function Toolbar({ children }) {
    return (
        <Header
            className="hippo-toolbar"
            fixed colorIndex="light-2" align="center"
            pad={{ horizontal: 'small', vertical: 'small', between: 'small' }}
        >
            {children}
        </Header>
    );
}
