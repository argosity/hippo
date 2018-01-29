import React from 'react';
import PropTypes from 'prop-types';
import cn from 'classnames';
import { observer } from 'mobx-react';
import { Grid } from 'grommet';
import styled, { ThemeProvider } from 'styled-components';
import baseTheme from 'grommet/themes/vanilla';
import ScreenInstance from '../screens/instance';

@observer
export default class Screen extends React.Component {

    static Instance = ScreenInstance;

    static defaultProps = {
        className: '',
        theme: baseTheme,
    }

    static contextTypes = {
        theme: PropTypes.object,
    }

    static propTypes = {
        screen:    PropTypes.instanceOf(ScreenInstance).isRequired,
        children:  PropTypes.node.isRequired,
        className: PropTypes.string,
    }

    render() {
        const { className, screen, ...gridProps } = this.props;
        return (
            <ThemeProvider theme={this.context.theme || baseTheme}>
                <Grid
                    data-screen-id={this.props.screen.definition.id}
                    rows={['xxsmall', 'flex', 'xsmall']}
                    columns={['full']}
                    gap='small'
                    areas={[
                        { name: 'header', start: [0, 0], end: [1, 0] },
                        { name: 'main', start: [0, 1], end: [0, 1] },
                        { name: 'footer', start: [0, 2], end: [1, 2] },
                    ]}
                    className={cn('hippo-screen', screen.definition.id, className, {
                        'is-active': screen.isActive,
                    })}
                    {...gridProps}
                >
                    {this.props.children}
                </Grid>
            </ThemeProvider>
        );
    }

}

Screen.body = styled.div`
grid-area: body;
flex: 1;
overflow: auto;
-webkit-overflow-scrolling: touch;
align-content: flex-start;
`;
