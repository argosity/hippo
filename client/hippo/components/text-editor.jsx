import React from 'react';
import PropTypes from 'prop-types';
import { action, observable } from 'mobx';
import { observer, Provider, PropTypes as MobxPropTypes } from 'mobx-react';
import { Quill, defaultModules } from './text-editor/quill';
import TextEditorWrapper from './text-editor/text-editor-wrapper';


@observer
export default class TextEditor extends React.Component {

    static defaultProps = {
        assets: observable.array(),
    }

    static propTypes = {
        defaultContent: PropTypes.object,
        onReady: PropTypes.func.isRequired,
        assets:  MobxPropTypes.observableArray,
    }

    @action.bound setRef(r) {
        this.body = r;
    }

    componentWillUnmount() {
        this.editor.disable();
    }

    componentDidMount() {
        this.editor = new Quill(this.body, {
            modules: defaultModules,
            theme: 'snow',
        });
        if (this.props.onReady) {
            this.props.onReady(this);
        }
        this.editor.focus();
    }

    get contents() {
        return {
            delta: this.editor.getContents(),
            html: this.body.querySelector('.ql-editor').innerHTML,
        };
    }

    set contents(delta) {
        this.editor.setContents(delta.ops);
    }

    @action.bound
    onEditStateChange(state) {
        this.content = state;
        this.props.onChange(state);
    }

    render() {
        return (
            <Provider
                assets={this.props.assets}
            >
                <TextEditorWrapper
                    className="text-editor" innerRef={this.setRef}
                />
            </Provider>
        );
    }

}
