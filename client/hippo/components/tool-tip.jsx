import React from 'react'; // eslint-disable-line no-unused-vars
import { Tooltip as Tippy } from 'react-tippy';

import 'react-tippy/dist/tippy.css';

// Use a wrapper component even though it doesn't really add any functionality
// In the future we'll add a Manager wrapper so that multiple tooltips cannot be shown at once
export default function ToolTip({ children, ...tipProps }) {
    return (
        <Tippy
            {...tipProps}
        >
            {children}
        </Tippy>
    );
}
