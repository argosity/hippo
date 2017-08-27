import React from 'react';

import PropTypes from 'prop-types';

import { action } from 'mobx';
import { observer } from 'mobx-react';
import Icon from '../components/icon';

import Anchor from 'grommet/components/Anchor';

@observer
export default class MenuOption extends React.Component {
    static propTypes = {
        screen: PropTypes.shape({
            title:   PropTypes.string.isRequired,
            icon:    PropTypes.string.isRequired,
            display: PropTypes.func.isRequired,
        }).isRequired,
    }

    static contextTypes = {
        viewport: PropTypes.object,
    }

    @action.bound
    activateScreen() {
        this.props.screen.display();
    }

    render() {
        const { screen } = this.props;
        return (
            <Anchor path={`/${screen.id}/`} onClick={this.activateScreen}>
                <Icon name={screen.icon} />
                {screen.title}
            </Anchor>
        );
    }
}
