import React from 'react';
import PropTypes from 'prop-types';
import { observer } from 'mobx-react';
import { Box, Heading } from 'grommet';
import { MenuOption } from './menu-option';

import Icon  from '../components/icon';

@observer
export default class Group extends React.Component {

    static propTypes = {
        group: PropTypes.shape({
            active: PropTypes.bool.isRequired,
            title:  PropTypes.string.isRequired,
            icon:   PropTypes.string.isRequired,
        }).isRequired,
        onMenuSelection: PropTypes.func.isRequired,
    }

    render() {
        const { group } = this.props;
        return (
            <Box direction="column" align="start" justify="between" primary>
                <Box align="end" pad={{ horizontal: 'medium' }}>
                    <Heading level={3}>
                        {group.title}
                        <Icon name={group.icon} />
                    </Heading>
                </Box>
                {group.screens.map(s => <MenuOption
                    key={s.id}
                    screen={s}
                    onSelection={this.props.onMenuSelection}
                />)}
            </Box>
        );
    }

}
