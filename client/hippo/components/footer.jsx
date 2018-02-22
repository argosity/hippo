import React from 'react'; // eslint-disable-line no-unused-vars
import { Toolbar, SaveButton } from './toolbar';

export { SaveButton };

export function Footer({ children, ...props }) {
    return (
        <Toolbar
            gridArea="footer"
            align="end"
            justify="end"
            background="white"
            direction="row"
            {...props}
        >
            {children}
        </Toolbar>
    );
}
