import React from 'react';

import { bindAll } from 'lodash';
import { observer } from 'mobx-react';
import Icon from 'lanes/components/icon';

import Anchor from 'grommet/components/Anchor';

@observer
export default class MenuOption extends React.Component {

    static propTypes = {
        screen: React.PropTypes.shape({
            title:   React.PropTypes.string.isRequired,
            icon:    React.PropTypes.string.isRequired,
            display: React.PropTypes.func.isRequired,
        }).isRequired,
    }

    static contextTypes = {
        viewport: React.PropTypes.object,
    }

    constructor() {
        super();
        bindAll(this, 'activateScreen');
    }

    activateScreen(ev) {
        this.props.screen.display();
    }


    render() {
        const { screen } = this.props;
        return (
            <Anchor path={`/${screen.id}/`} onClick={this.activateScreen}>
                {screen.title}
                <Icon type={screen.icon} />
            </Anchor>
        );
    }
}
//<div>{screen.title}</div>
