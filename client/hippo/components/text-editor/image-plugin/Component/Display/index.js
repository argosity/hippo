// @flow
import React from 'react';
import { observer, inject } from 'mobx-react';
import { action, computed } from 'mobx';
import { find } from 'lodash';
import Dropzone from 'react-dropzone';
import Button from 'grommet/components/Button';
import ImageIcon from 'grommet/components/icons/base/Image';
import cn from 'classnames';

const iconStyle = {
    width: '100%',
    height: 'auto',
    padding: '0',
    color: '#aaa',
    textAlign: 'center',
    minWidth: 64,
    minHeight: 64,
    maxHeight: 256,
};


@inject('assets')
@observer
export default class Display extends React.PureComponent {

    @computed get asset() {
        return find(this.props.assets, asset =>
            asset.metadata && asset.metadata.nodeId === this.props.id);
    }

    @action.bound
    onFileDrop(files) {
        let asset = this.asset;
        if (!asset) {
            this.props.assets.push({ metadata: { nodeId: this.props.id } });
            asset = this.props.assets.get(this.props.assets.length - 1);
        }

        asset.setFile(files[0]).then(() => {
            this.props.onChange({ src: asset.previewUrl });
            asset.save().then(() => {
                this.props.onChange({
                    assetId: asset.id, src: asset.urlFor(),
                });
            });
        });
    }

    renderImage() {
        const { state: { src } } = this.props;
        return src ? <img className="content-image" src={src} /> : <ImageIcon style={iconStyle} />;
    }

    @action.bound
    onAddClick() {
        this.dropZone.open();
    }

    render() {
        const { isEditMode, state, focused } = this.props;
        if (isEditMode) {
            return (
                <div className={cn('content-image-wrapper', { focused })}>
                    <Button onClick={this.onAddClick}>{state.src ? 'Change' : 'Add'}</Button>
                    <Dropzone
                        ref={dz => (this.dropZone = dz)}
                        style={{}}
                        disableClick
                        multiple={false}
                        onDrop={this.onFileDrop}
                        className="image-drop-zone"
                    >
                        {this.renderImage()}
                    </Dropzone>
                </div>
            );
        }
        return this.renderImage();
    }

}
