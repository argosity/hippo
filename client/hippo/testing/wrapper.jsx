import Grommet from 'grommet/components/Grommet';
import { Provider } from 'mobx-react';
import { isEmpty } from 'lodash';
import { ThemeProvider } from 'styled-components';
import { Router } from 'react-router-dom';
import createBrowserHistory from 'history/createBrowserHistory';
import { RouterStore, syncHistoryWithStore } from 'mobx-react-router';
import { base as grommetTheme } from 'grommet/themes';


const TestWrapper = ({ history, routing, children }, { theme }) => {
    /* eslint-disable */
    if (!routing) routing = new RouterStore();
    if (!history) history = syncHistoryWithStore(createBrowserHistory(), routing);
    if (isEmpty(theme)) theme = baseTheme;
    /* eslint-enable */
    return (
        <Grommet theme={grommetTheme}>
            <Provider routing={routing}>
                <Router history={history}>
                    <ThemeProvider theme={grommetTheme}>
                        {children}
                    </ThemeProvider>
                </Router>
            </Provider>
        </Grommet>
    );
};

export default TestWrapper;
