import React from 'react';
import { isEmpty } from 'lodash';
import PropTypes from 'prop-types';
import { observable } from 'mobx';
import { PropTypes as MobxPropTypes, Provider as MobxProvider, observer } from 'mobx-react';
import { ThemeProvider } from 'styled-components';
import baseTheme from 'grommet/themes/vanilla';
import { observePubSub } from '../../models/pub_sub';
import Layout from './layout';
import { FormState } from './api';
import Screen from '../screen';

const Provider = ({ formState, children }, context) => {
    const theme = isEmpty(context.theme) ? baseTheme : context.theme;
    return (
        <MobxProvider formState={formState}>
            <ThemeProvider theme={theme}>
                {children}
            </ThemeProvider>
        </MobxProvider>
    );
};


Provider.contextTypes = {
    theme: PropTypes.object,
};


@observer
export default class FormWrapper extends React.Component {

    static propTypes = {
        tag: PropTypes.string,
        className: PropTypes.string,
        children: PropTypes.node.isRequired,
        state: PropTypes.instanceOf(FormState),
        model: MobxPropTypes.observableObject,
        screen: PropTypes.instanceOf(Screen.Instance),
    }

    @observable state;

    constructor(props) {
        super(props);
        this.state = props.state || new FormState();
    }

    componentDidMount() {
        if (this.props.model) {
            this.state.setFromModel(this.props.model);
        }
    }

    renderTagless() {
        return (
            <Provider formState={this.state}>
                {this.props.children}
            </Provider>
        );
    }

    persistTo(model) {
        this.state.persistTo(model);
    }

    renderTagged() {
        const {
            state, props: { tag: Tag, children, model: _, ...otherProps },
        } = this;
        return (
            <Provider formState={state}>
                <Tag {...otherProps}>
                    {children}
                </Tag>
            </Provider>
        );
    }

    renderScreen() {
        const {
            tag: _, state, children, screen, model: __, ...otherProps
        } = this.props;
        return (
            <Provider formState={state}>
                <Screen screen={screen} {...otherProps}>
                    {children}
                </Screen>
            </Provider>
        );
    }

    renderLayout() {
        const {
            tag: _, state, children, model: __, ...otherProps
        } = this.props;
        return (
            <Provider formState={state}>
                <Layout {...otherProps}>
                    {children}
                </Layout>
            </Provider>
        );
    }

    render() {
        if (this.props.model) { observePubSub(this.props.model); }
        if (this.props.screen) { return this.renderScreen(); }
        if (this.props.grid) { return this.renderLayout(); }
        return this.props.tag ? this.renderTagged() : this.renderTagless();
    }

}
