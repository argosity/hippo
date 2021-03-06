import React from 'react';
import PropTypes from 'prop-types';
import { observable, action } from 'mobx';
import { observer }   from 'mobx-react';
import { map, compact, invoke } from 'lodash';
import { Heading, FieldsLayout } from '../components/form';
import Screen from '../components/screen';
import Asset  from '../components/asset';
import Settings from '../models/system-setting';
import Warning from '../components/warning-notification';
import { Toolbar, SaveButton } from '../components/toolbar';
import ScreenInstance from './instance';
import Extensions from '../extensions';
import MailerConfig from './system-settings/mailer-config';
import Config from '../config';
import TenantSettings from  './system-settings/tenant';
import './system-settings/system-settings.scss';

@observer
export default class SystemSettings extends React.Component {

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
        this.settings.sync.fetch();
    }

    @action.bound
    onSave() {
        const saves = [];
        ['logo', 'print_logo'].forEach((attr) => {
            if (this.settings[attr] && this.settings[attr].isDirty) {
                saves.push(this.settings[attr].save());
            }
        });
        Promise.all(saves).then(() => {
            Config.logo = this.settings.logo ? this.settings.logo.file_data : null;
            this.extensionPanelRefs.forEach(panel => invoke(panel, 'onSave'));
            this.tenantSettings.onSave();
            this.settings.save();
        });
    }

    @action.bound
    setTenantRef(ts) {
        this.tenantSettings = ts;
    }

    render() {
        return (
            <Screen {...this.props}>
                <Toolbar>
                    <SaveButton
                        model={this.settings}
                        onClick={this.onSave}
                    />
                </Toolbar>
                <Screen.body>
                    <Heading>{this.props.screen.definition.title}</Heading>
                    <Warning message={this.settings.errorMessage} />
                    <TenantSettings ref={this.setTenantRef} />
                    <Heading>Images</Heading>
                    <FieldsLayout>
                        <Asset model={this.settings} name="logo" />
                        <Asset model={this.settings} name="print_logo" />
                    </FieldsLayout>
                    <MailerConfig
                        settings={this.settings.settings}
                        registerForSave={panel => this.extensionPanelRefs.set('mail', panel)}
                    />
                    {this.extensionPanels}
                </Screen.body>
            </Screen>
        );
    }

}
