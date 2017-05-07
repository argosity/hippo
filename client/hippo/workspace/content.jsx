import React from 'react';

import Tabs from './tabs';

import Box   from 'grommet/components/Box';
import Paragraph from 'grommet/components/Paragraph';

export default class Content extends React.Component {

    render() {
        return (
            <Box className="content-pane" justify="start" align="stretch" pad="none" direction="column" full="vertical">
                <Tabs />

                <Box justify="start" align="stretch" pad="none" flex="grow">
                    {this.props.children}
               </Box>

            </Box>
        );
    }
}
