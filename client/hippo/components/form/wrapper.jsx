import React from 'react';
import { isEmpty } from 'lodash';
import PropTypes from 'prop-types';
import { observable } from 'mobx';
import { PropTypes as MobxPropTypes, Provider as MobxProvider, observer } from 'mobx-react';
import { ThemeProvider } from 'styled-components';
import { base as grommetTheme } from 'grommet/themes';
import { observePubSub } from '../../models/pub_sub';
import Layout from './layout';
import { FormState } from './api';
import Screen from '../screen';

const Provider = ({ formState, children }, context) => {
    const theme = isEmpty(context.theme) ? grommetTheme : context.theme;
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

    renderTagless(body) {
        return (
            <Provider formState={this.state}>
                {body}
            </Provider>
        );
    }

    persistTo(model) {
        this.state.persistTo(model);
    }

    renderTagged(body) {
        const { tag: Tag, children: _, model: __, ...otherProps } = this.props;
        return (
            <Provider formState={this.state}>
                <Tag {...otherProps}>
                    {body}
                </Tag>
            </Provider>
        );
    }

    renderScreen(body) {
        const { tag: _, children: __, screen, model: ___, ...otherProps } = this.props;
        return (
            <Screen screen={screen} {...otherProps}>
                {body}
            </Screen>
        );
    }

    renderLayout(body) {
        const { children: _, model: __, ...otherProps } = this.props;
        return (
            <Layout {...otherProps}>
                {body}
            </Layout>
        );
    }

    render() {
        if (this.props.model) { observePubSub(this.props.model); }
        let body = this.props.children;
        if (this.props.screen) { body = this.renderScreen(body); }
        if (this.props.grid) { body = this.renderLayout(body); }
        return this.props.tag
            ? this.renderTagged(body) : this.renderTagless(body);
    }

}
