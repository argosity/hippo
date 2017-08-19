import React from 'react';
import PropTypes from 'prop-types';
import { observer } from 'mobx-react';
import Screen from 'hippo/components/screen';

@observer
export default class <%= screen_class %> extends React.PureComponent {

    static propTypes = {
        screen: PropTypes.instanceOf(Screen.Instance).isRequired,
    }

    render() {
        return (
            <Screen screen={this.props.screen}>
                <div className="fancy-header">
                    <h1>Hello bright shiny world</h1>
                    <h2>Served by the <%=namespace%> extension&rsquo;s <%= class_name %> screen</h2>
                </div>
            </Screen>
        );
    }
}
