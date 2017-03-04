import React from 'react';
import classnames from 'classnames';
import { observer } from 'mobx-react';
import { Grid } from 'react-flexbox-grid';
import Box from 'grommet/components/Box';
import Screens from '../screens';
import ScreenInstances from '../screens/instance';

const ScreenView = observer((props) => {
    const { screen: Screen, ...rest } = props;
    return (
        <Screen.component {...rest} screen={Screen} />
    );
});
ScreenView.displayName = 'ScreenView';

@observer
export default class Screen extends React.Component {

    static propTypes = {
        params: React.PropTypes.shape({
            screenId: React.PropTypes.string,
        }).isRequired,
    }

    componentDidMount() {
        const { screenId } = this.props.params;
        if (screenId) {
            const definition = Screens.all.get(screenId);
            if (definition) { definition.display(); }
        }
    }

    render() {
        return (
            <Box
                full
                className="screens-wrapper"
                justify="start"
                align="stretch"
                flex="grow"
            >
                {ScreenInstances.displaying.map(s =>
                    <ScreenView key={s.id} {...this.props.params} screen={s} />)}
            </Box>

        );
    }
}
