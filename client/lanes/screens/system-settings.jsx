import React from 'react';
import PropTypes from 'prop-types';
import { observable, action, computed } from 'mobx';
import { observer }   from 'mobx-react';

import Heading from 'grommet/components/Heading';

import Header from 'grommet/components/Header';
import Button from 'grommet/components/Button';
import SaveIcon from 'grommet/components/icons/base/Save';

import Screen from 'lanes/components/screen';
import Asset  from 'lanes/components/asset';
import Settings from 'lanes/models/system-setting';

import {Row, Col} from 'react-flexbox-grid';
import ScreenInstance from 'lanes/screens/instance';

@observer
export default class SystemSettings extends React.PureComponent {

    @observable settings = new Settings();

    static propTypes = {
        screen:    PropTypes.instanceOf(ScreenInstance).isRequired,
    }

    constructor(props) {
        super(props);
        this.settings.fetch();
    }

    @action.bound
    onSave() {
        this.settings.save();
    }

    render() {
        return (
            <Screen {...this.props}>
                <Header fixed>
                    <Button
                        primary
                        icon={<SaveIcon />}
                        label='Save'
                        onClick={this.onSave}
                    />
                </Header>
                <Heading>{this.props.screen.definition.title}</Heading>

                <Row>
                    <Col sm={4} xs={12}>
                        <Asset model={this.settings} name="logo" />
                    </Col>
                    <Col sm={4} xs={12}>
                        <Asset model={this.settings} name="print_logo" />
                    </Col>
                </Row>
            </Screen>
        );
    }
}
