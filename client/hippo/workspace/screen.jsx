import React from 'react';
import PropTypes from 'prop-types';
import { observer, inject } from 'mobx-react';
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

@inject('routing')
@observer
export default class Screen extends React.Component {

    static propTypes = {
        match: PropTypes.shape({
            params: PropTypes.shape({
                screenId: PropTypes.string,
            }),
        }).isRequired,
    }

    componentWillReceiveProps(nextProps) {
        this.setScreen(nextProps.match.params);
    }

    componentDidMount() {
        this.setScreen(this.props.match.params);
    }

    setScreen({ screenId }) {
        if (screenId) {
            const definition = Screens.all.get(screenId);
            if (definition) { definition.display(); }
        }
    }

    render() {
        return (
            <Box
                className="screens-wrapper"
                justify="start"
                align="stretch"

            >
                {displaying.models.map(s =>
                    <ScreenView
                        key={s.id}
                        {...this.props.match.params}
                        screen={s}
                    />)}
            </Box>

        );
    }

}
