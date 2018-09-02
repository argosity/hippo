import React from 'react';
import PropTypes from 'prop-types';
import { action, computed } from 'mobx';
import { observer, inject } from 'mobx-react';
import { RoutedAnchor } from 'grommet';
import styled, { css } from 'styled-components';
import { colorForName } from 'grommet/utils/colors';
import Icon from '../components/icon';

const activeStyle = css`
  background-color: ${props => colorForName('border', props.theme)};
`;

const MenuLink = styled(RoutedAnchor)`
  display: flex;
  > * {
    display: flex;
    align-items: center;
  }
  padding: 10px 0 10px 10px;
  color: ${props => colorForName('light-1', props.theme)};
  ${props => props.isActive && activeStyle}
  &:hover {
    text-decoration: none;
    background-color: ${props => colorForName('neutral-3', props.theme)};
  }
`;

export { MenuLink };

@inject('routing')
@observer
export class MenuOption extends React.Component {

    static propTypes = {
        onSelection: PropTypes.func.isRequired,
        screen: PropTypes.shape({
            title:   PropTypes.string.isRequired,
            icon:    PropTypes.string.isRequired,
            display: PropTypes.func.isRequired,
        }).isRequired,
    }

    static contextTypes = {
        router: PropTypes.object,
    }

    @action.bound
    activateScreen() {
        this.props.onSelection(this.props.screen);
        this.props.screen.display();
    }

    @computed get path() {
        return `/${this.props.screen.id}`;
    }

    @computed get isActive() {
        const { location } = this.props.routing;
        return this.path === location.pathname;
    }


    render() {
        const { screen } = this.props;
        return (
            <MenuLink
                isActive={this.isActive}
                icon={<Icon name={screen.icon} />}
                label={screen.title}
                path={this.path}
                onClick={this.activateScreen}
            />
        );
    }

}
