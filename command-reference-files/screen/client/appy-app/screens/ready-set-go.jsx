import React from 'react';
import { observer } from 'mobx-react';
import Screen from 'hippo/components/screen';

@observer
export default class ReadySetGo extends React.PureComponent {

    static propTypes = {
        screen: React.PropTypes.instanceOf(Screen.Instance).isRequired,
    }

    render() {
        return (
            <Screen screen={this.props.screen}>
                <div className="fancy-header">
                    <h1>Hello bright shiny world</h1>
                    <h2>Served by the AppyApp extension&rsquo;s ReadySetGo screen</h2>
                </div>
            </Screen>
        );
    }
}
