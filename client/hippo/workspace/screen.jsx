import React from 'react';
import PropTypes from 'prop-types';
import { observer } from 'mobx-react';
import Box from 'grommet/components/Box';
import Screens from '../screens';
import { displaying } from '../screens/instance';

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
        match: PropTypes.shape({
            params: PropTypes.shape({
                screenId: PropTypes.string,
            }),
        }).isRequired,
    }

    componentDidMount() {
        const { screenId } = this.props.match.params;
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
                {displaying.models.map(s =>
                    <ScreenView key={s.id} {...this.props.match.params} screen={s} />)}
            </Box>

        );
    }

}
