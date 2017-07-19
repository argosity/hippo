// @flow
import React from 'react';
import { inject, observer } from 'mobx-react';
import Dropzone from 'react-dropzone';
import { action } from 'mobx';
import { BottomToolbar } from 'ory-editor-ui';

import Display from '../Display';

@inject('model', 'images_attribute')
@observer
export default class Form extends React.PureComponent {
    get assets() {
        return this.props.model[this.props.images_attribute];
    }

    @action.bound
    onFileDrop(files) {
        this.assets.push({});
        const asset = this.assets.at(this.assets.length - 1);
        asset.setFile(files[0]);
    }

    render() {
        const { props } = this;

        return (
            <div>
                <Display {...props} />
                <BottomToolbar open={props.focused}>
                    <Dropzone
                        onDrop={this.onFileDrop}
                    >
                        Drop a file here, or click to select one to upload.
                    </Dropzone>
                </BottomToolbar>
            </div>
        );
    }
}
