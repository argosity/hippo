import React from 'react';
import PropTypes from 'prop-types';
import { observer } from 'mobx-react';
import Box from 'grommet/components/Box';
import Menu from 'grommet/components/Menu';

import MenuOption from './menu-option';
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
            <Menu direction="column" align="start" justify="between" primary>
                <Box align="end" pad={{ horizontal: 'medium' }}>
                    <Heading tag="h4" strong>
                        {group.title}
                        <Icon name={group.icon} />
                    </Heading>
                </Header>
                {group.screens.map(s =>
                    <MenuOption
                        key={s.id}
                        screen={s}
                        onSelection={this.props.onMenuSelection}
                    />)}
            </Menu>
        );
    }

}
