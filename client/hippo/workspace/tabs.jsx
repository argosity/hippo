import React from 'react';
import PropTypes from 'prop-types';
import { observer } from 'mobx-react';
import classnames from 'classnames';
import Icon from '../components/icon';
import ScreenInstances from '../screens/instance';

import Tabs from 'grommet/components/Tabs';
import Tab from 'grommet/components/Tab';

@observer
export class ScreenTab extends React.Component {
    static propTypes = {
        screen: PropTypes.shape({
            title: PropTypes.string.isRequired,
            definition: PropTypes.shape({
                icon:    PropTypes.string.isRequired,
            }).isRequired,
        }).isRequired,
    }

    setModelState(nextState) {
        if (this.model.active) {
            _.dom(document.head).qs('title').text = this.model.title();
            this.context.viewport.history.replace(this.model.historyUrl());
        }
        if (Hippo.Screens.Definitions.displaying.length === 0) {
            this.context.viewport.history.push('/');
        }
        return (
            this.setState(nextState)
        );
    }

    activate() {
        this.model.active = true;
        this.context.viewport.history.push(this.model.historyUrl());
        return (
            null
        );
    }

    close() { return this.model.remove(); }

    render() {
        const { screen } = this.props;
        // const title = <span><Icon type="hourglass" />{screen.title}</span>
        return (
            <Tab title={screen.title} />
        );
    }
}

const ScreenTabs = observer(() => (
    <Tabs justify="start">
        {ScreenInstances.displaying.map(s => <ScreenTab key={s.id} screen={s} />)}
    </Tabs>
));
ScreenTabs.displayName = 'NavbarTabs';
export default ScreenTabs;
