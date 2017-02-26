import React from 'react';
import classnames from 'classnames';
import { bindAll } from 'lodash';
import { observer } from 'mobx-react';

import Heading from 'grommet/components/Heading';
import Header  from 'grommet/components/Header';

import MenuOption from './menu-option';
import Menu    from 'grommet/components/Menu';
import Icon   from '../components/icon';
@observer
export default class Group extends React.Component {

    static propTypes = {
        group: React.PropTypes.shape({
            active: React.PropTypes.bool.isRequired,
            title:  React.PropTypes.string.isRequired,
            icon:   React.PropTypes.string.isRequired,
        }).isRequired,
    }

    render() {
        const { group } = this.props;
        return (
            <Menu direction="column" align="start" justify="between" primary>
                <Header align="end" pad={{ horizontal: 'medium' }}>
                    <Heading tag="h4" strong>
                        {group.title}
                        <Icon type={group.icon} />
                    </Heading>
                </Header>
                {group.screens.map(s => <MenuOption key={s.id} screen={s} />)}
            </Menu>
        );
    }
}
