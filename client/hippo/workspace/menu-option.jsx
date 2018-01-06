import React from 'react';
import PropTypes from 'prop-types';
import { action } from 'mobx';
import { observer } from 'mobx-react';
import { RoutedAnchor } from 'grommet';
import styled from 'styled-components';
import color from 'grommet/utils/colors';
import Icon from '../components/icon';

const Link = styled(RoutedAnchor)`
  padding: 5px 0 5px 10px;
  color: ${props => color.colorForName('light-1', props.theme)};
  &:hover {
    text-decoration: none;
    background-color: ${props => color.colorForName('border', props.theme)};
  }
`;

@observer
export default class MenuOption extends React.Component {

    static propTypes = {
        onSelection: PropTypes.func.isRequired,
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
        this.props.onSelection(this.props.screen);
        this.props.screen.display();
    }

    render() {
        const { screen } = this.props;
        return (
            <Link
                icon={<Icon name={screen.icon} />}
                label={screen.title}
                path={`/${screen.id}`} onClick={this.activateScreen}
            />
        );
    }

}
