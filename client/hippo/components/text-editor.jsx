import React from 'react';
import PropTypes from 'prop-types';
import { get, find } from 'lodash';
import { action, autorun } from 'mobx';
import { observer, Provider } from 'mobx-react';
import Page from '../models/page';
import Asset from '../models/asset';
import { Quill, defaultModules } from './text-editor/quill';
import TextEditorWrapper from './text-editor/text-editor-wrapper';
import imageUploader from './text-editor/image-uploader';
import './text-editor/image';

@observer
export default class TextEditor extends React.Component {

    static propTypes = {
        page: PropTypes.instanceOf(Page).isRequired,
    }

    @action.bound setRef(r) {
        this.body = r;
    }

    @action deleteUnusedAssets({ retain, destroyIfMissing }) {
        destroyIfMissing.forEach((op) => {
            const id = get(op, 'insert.image.id');
            if (id && !find(retain, o => id === get(o, 'insert.image.id'))) {
                const asset = new Asset({ id: parseInt(id, 10) });
                asset.destroy();
            }
        });
    }


    save() {
        const currentOps = this.editor.getContents().ops;

        this.deleteUnusedAssets({
            retain: currentOps,
            destroyIfMissing: this.props.page.editorContent,
        });

        Object.assign(this.props.page, {
            contents: currentOps,
            html: this.body.querySelector('.ql-editor').innerHTML,
        });
        return this.props.page.save();
    }

    componentWillUnmount() {
        this.deleteUnusedAssets({
            retain: this.props.page.editorContent,
            destroyIfMissing: this.editor.getContents().ops,
        });

        if (this.cancelAutoSet) {
            this.cancelAutoSet();
        }
        if (this.editor) {
            this.editor.disable();
        }
    }

    componentDidMount() {
        this.editor = new Quill(this.body, {
            modules: defaultModules,
            page: this.props.page,
            theme: 'snow',
        });
        this.editor.getModule('toolbar').addHandler('image', imageUploader);

        if (this.props.onReady) {
            this.props.onReady(this);
        }
        this.cancelAutoSet = autorun(() => {
            this.editor.setContents(this.props.page.editorContent);
        });
        this.editor.focus();
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
