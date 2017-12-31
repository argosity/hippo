import React from 'react';
import PropTypes from 'prop-types';
import { action, observable } from 'mobx';
import { observer, Provider, PropTypes as MobxPropTypes } from 'mobx-react';
import HippoUploadAdapter from './text-editor/upload-adapter';
import './text-editor/text-editor.scss';

const BalloonEditor = require('@ckeditor/ckeditor5-build-balloon');

BalloonEditor.build.plugins.push(HippoUploadAdapter);

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
        this.editor.destroy();
    }

    componentDidMount() {
        BalloonEditor.create(this.body, {
            assets: this.props.assets,
            image: {
                toolbar: [
                    'imageTextAlternative', '|',
                    'imageStyleAlignLeft', 'imageStyleFull', 'imageStyleAlignRight',
                ],
                styles: [
                    // This option is equal to a situation where no style is applied.
                    'imageStyleFull',
                    // This represents an image aligned to left.
                    'imageStyleAlignLeft',
                    // This represents an image aligned to right.
                    'imageStyleAlignRight',
                ],
            },
        }).then((e) => {
            this.editor = e;
            this.props.onReady(this);
        });
    }

    get contents() {
        return this.editor.getData();
    }

    set contents(html) {
        this.editor.setData(html || '<p>Edit me…</p>');
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

                <div className="text-editor" ref={this.setRef}>
                </div>

            </Provider>
        );
    }

}
