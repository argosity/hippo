import Grommet from 'grommet/components/Grommet';
import { Provider } from 'mobx-react';
import { isEmpty } from 'lodash';
import { ThemeProvider } from 'styled-components';
import { Router } from 'react-router-dom';
import createBrowserHistory from 'history/createBrowserHistory';
import { RouterStore, syncHistoryWithStore } from 'mobx-react-router';
import baseTheme from 'grommet/themes/vanilla';

const TestWrapper = ({ history, routing, children }, { theme }) => {
    /* eslint-disable */
    if (!routing) routing = new RouterStore();
    if (!history) history = syncHistoryWithStore(createBrowserHistory(), routing);
    if (isEmpty(theme)) theme = baseTheme;
    /* eslint-enable */
    return (
        <Grommet>
            <Provider routing={routing}>
                <Router history={history}>
                    <ThemeProvider theme={theme}>
                        {children}
                    </ThemeProvider>
                </Router>
            </Provider>
        </Grommet>
    );
};

export default TestWrapper;
