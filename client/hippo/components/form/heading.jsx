import React from 'react'; // eslint-disable-line no-unused-vars
import { Box, Heading as GrommetHeading } from 'grommet';

export default function Heading({ children, size = 3, ...props }) {
    return (
        <Box margin="small" {...props}>
            <GrommetHeading level={size} margin="none">
                {children}
            </GrommetHeading>
        </Box>
    );
}
