import React from 'react';
import PropTypes from 'prop-types';
import { observable, action } from 'mobx';
import { observer }   from 'mobx-react';
import { map, compact, invoke } from 'lodash';
import Heading from 'grommet/components/Heading';
import Header from 'grommet/components/Header';
import Button from 'grommet/components/Button';
import SaveIcon from 'grommet/components/icons/base/Save';

import Screen from 'hippo/components/screen';
import Asset  from 'hippo/components/asset';
import Settings from 'hippo/models/system-setting';

import { Row, Col } from 'react-flexbox-grid';
import ScreenInstance from 'hippo/screens/instance';
import Extensions from '../extensions';
import MailerConfig from './system-settings/mailer-config';
import TenantSettings from  './system-settings/tenant';
import './system-settings/system-settings.scss';

@observer
export default class SystemSettings extends React.PureComponent {
    @observable settings = new Settings();
    extensionPanelRefs = new Map();

    static propTypes = {
        screen: PropTypes.instanceOf(ScreenInstance).isRequired,
    }

    renderExtPanel(ext) {
        const { systemSettingsComponent: Panel } = ext;
        if (!Panel) return null;
        return (
            <div key={`${ext.id}-settings`} className="section">
                <Panel
                    extension={ext}
                    settings={this.settings.settings}
                    registerForSave={panel => this.extensionPanelRefs.set(ext.id, panel)}
                />
            </div>
        );
    }


    get extensionPanels() {
        return compact(map(Extensions.instances.values(), panel => this.renderExtPanel(panel)));
    }

    constructor(props) {
        super(props);
        this.settings.fetch();
    }

    @action.bound
    onSave() {
        this.extensionPanelRefs.forEach(panel => invoke(panel, 'onSave'));
        this.tenantSettings.onSave();
        this.settings.save();
    }

    @action.bound
    setTenantRef(ts) {
        this.tenantSettings = ts;
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
                <TenantSettings ref={this.setTenantRef} />
                <Heading tag="h3">Images</Heading>
                <Row>
                    <Col sm={4} xs={12}>
                        <Asset model={this.settings} name="logo" />
                    </Col>
                    <Col sm={4} xs={12}>
                        <Asset model={this.settings} name="print_logo" />
                    </Col>
                </Row>
                <MailerConfig
                    settings={this.settings.settings}
                    registerForSave={panel => this.extensionPanelRefs.set('mail', panel)}
                />
                {this.extensionPanels}
            </Screen>
        );
    }
}
