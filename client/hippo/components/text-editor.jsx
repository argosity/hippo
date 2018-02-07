import React from 'react';
import PropTypes from 'prop-types';
import { action, observable } from 'mobx';
import { observer, Provider, PropTypes as MobxPropTypes } from 'mobx-react';
import { Quill, defaultModules } from './text-editor/quill';
import TextEditorWrapper from './text-editor/text-editor-wrapper';
import imageUploader from './text-editor/image-uploader';


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
            assets: this.props.assets,
            theme: 'snow',
        });
        // this.editor.keyboard.addBinding({
        //     key: 8,
        //     shortKey: false,
        //     handler: (range, context) => {
        //         console.log(range, context);
        //     }
        //         // const deleted = d.ops.find(o => has(o, 'delete'));
        //         // if (deleted) {
        //         //     debugger
        //         //     console.log(od.ops[0]);
        //         // }
        // });
        this.editor.getModule('toolbar').addHandler('image', imageUploader);
        if (this.props.onReady) {
            this.props.onReady(this);
        }
        this.editor.focus();
    }

    get contents() {
        return {
            contents: this.editor.getContents().ops,
            html: this.body.querySelector('.ql-editor').innerHTML,
        };
    }

    set contents(contents) {
        this.editor.setContents(contents);
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
