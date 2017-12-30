import React from 'react';
import PropTypes from 'prop-types';
import { action, observable } from 'mobx';
import { observer, Provider, PropTypes as MobxPropTypes } from 'mobx-react';

import BalloonEditor from '@ckeditor/ckeditor5-editor-balloon/src/ballooneditor';
import EssentialsPlugin from '@ckeditor/ckeditor5-essentials/src/essentials';
import AutoformatPlugin from '@ckeditor/ckeditor5-autoformat/src/autoformat';
import BoldPlugin from '@ckeditor/ckeditor5-basic-styles/src/bold';
import ItalicPlugin from '@ckeditor/ckeditor5-basic-styles/src/italic';
import BlockquotePlugin from '@ckeditor/ckeditor5-block-quote/src/blockquote';
import HeadingPlugin from '@ckeditor/ckeditor5-heading/src/heading';
import ImagePlugin from '@ckeditor/ckeditor5-image/src/image';
import ImagecaptionPlugin from '@ckeditor/ckeditor5-image/src/imagecaption';
import ImagestylePlugin from '@ckeditor/ckeditor5-image/src/imagestyle';
import ImagetoolbarPlugin from '@ckeditor/ckeditor5-image/src/imagetoolbar';
import LinkPlugin from '@ckeditor/ckeditor5-link/src/link';
import ListPlugin from '@ckeditor/ckeditor5-list/src/list';
import ParagraphPlugin from '@ckeditor/ckeditor5-paragraph/src/paragraph';
import ImageuploadPlugin from '@ckeditor/ckeditor5-upload/src/imageupload';

import HippoUploadAdapter from './text-editor/upload-adapter';
import './text-editor/text-editor.scss';

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
        BalloonEditor.create(this.body, {
            plugins: [
                EssentialsPlugin,
                AutoformatPlugin,
                BoldPlugin,
                ItalicPlugin,
                BlockquotePlugin,
                HeadingPlugin,
                ImagePlugin,
                ImagecaptionPlugin,
                ImagestylePlugin,
                ImagetoolbarPlugin,
                LinkPlugin,
                ListPlugin,
                ParagraphPlugin,
                ImageuploadPlugin,
                HippoUploadAdapter,
            ],
            assets: this.props.assets,
            toolbar: {
                items: [
                    'headings',
                    'bold',
                    'italic',
                    'link',
                    'bulletedList',
                    'numberedList',
                    'blockQuote',
                    'undo',
                    'redo',
                ],
            },
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
        this.editor.setData(html);
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
