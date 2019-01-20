import React from 'react';
import PropTypes from 'prop-types';
import { action } from 'mobx';
import { observer }   from 'mobx-react';
import cn from 'classnames';
import { titleize } from 'hippo/lib/util';
import Dropzone from 'react-dropzone';
import styled from 'styled-components';
import { normalizeColor } from 'grommet/utils/colors';
import { base as grommetTheme } from 'grommet/themes';
import { Box, Text, Button } from 'grommet';
import { Document } from 'grommet-icons';
import { BaseModel } from '../models/base';
import { StyledWrapper } from './form/field-wrapper';

const PreviewWrapper = styled.div`
position: relative;
img {
  max-width: 100%;
  max-height: 100%;
}
button {
  position: absolute;
  right: 20px;
  top: 20px;
  opacity: 0.3;
  &:hover {
    opacity: 1;
  }
}
`;

const AssetWrapper = styled(StyledWrapper)`
border-bottom: 0;
.drop-zone { height: 100%; }
border: ${props => props.theme.global.borderSize.small} dashed transparent;
overflow: auto;
min-height: 200px;
max-height: 300px;
-webkit-overflow-scrolling: touch;
.labels { padding-left: 0; }
&:hover {
 border-color: ${props => normalizeColor('light-3', props.theme)};
 cursor: pointer;
 background: ${props => normalizeColor('light-1', props.theme)};
}
`;

const DropZoneContent = styled.div`
    flex: 1;
`;

@observer
class Preview extends React.Component {

    render() {
        const { onRemove, asset } = this.props;

        if (asset && asset.exists) {
            const preview = asset.isImage
                ? <img src={asset.previewUrl} alt="" />
                : <Document size="xlarge" type="status" />;
            return (
                <PreviewWrapper>
                    <Button
                        primary
                        onClick={onRemove}
                        label={asset.isNew ? 'Clear' : 'Delete'}
                    />
                    {preview}
                </PreviewWrapper>

            );
        }
        return (
            <div>
                Drop a file here, or click to select one to upload.
            </div>
        );
    }

}

@observer
export default class Asset extends React.Component {

    static defaultProps = {
        label: '',
        className: '',
        tabIndex: 0,
        theme: grommetTheme,
    }

    static propTypes = {
        model:     PropTypes.instanceOf(BaseModel).isRequired,
        name:      PropTypes.string.isRequired,
        label:     PropTypes.string,
        className: PropTypes.string,
        tabIndex:  PropTypes.number,
    }

    @action.bound
    onDrop(files) {
        if (!this.asset) {
            this.props.model[this.props.name] = {};
        }
        this.asset.setFile(files[0]);
    }

    get asset() {
        return this.props.model[this.props.name];
    }

    get label() {
        return this.props.label || titleize(this.props.name);
    }

    @action.bound
    setDZRef(dz) {
        this.dropZone = dz;
    }

    @action.bound
    onKey(ev) {
        if ('Enter' === ev.key) {
            this.dropZone.open();
        }
    }

    @action.bound onRemove(ev) {
        ev.stopPropagation();
        if (this.asset.isNew) {
            this.props.model[this.props.name] = null;
        } else {
            this.asset.sync.destroy();
        }
    }

    render() {
        const {
            model, label: __, name: ___, tabIndex, height, ...wrapperProps
        } = this.props;

        let header;
        if (this.label || model.errorMessage) {
            header = (
                <Box
                    wrap
                    direction="row"
                    className="labels"
                    justify="between"
                    pad={{ horizontal: 'small', top: 'xsmall' }}
                >
                    <Text>{this.label}</Text>
                    <Text truncate color="status-critical">
                        {model.errorMessage}
                    </Text>
                </Box>
            );
        }

        return (
            <AssetWrapper
                height={height || 3}
                width={3}
                tabIndex={tabIndex}
                onKeyPress={this.onKey}
                {...wrapperProps}
            >
                <Dropzone
                    className={cn('drop-zone', {
                        'is-new': this.asset && this.asset.isNew,
                    })}
                    activeClassName="drop-zone-active"
                    onDrop={this.onDrop}
                    multiple={false}
                    ref={this.setDZRef}
                >
                    {({ getRootProps, getInputProps, isDragActive }) => (
                        <DropZoneContent
                            {...getRootProps()}
                            className={cn('dropzone', { 'dropzone--isActive': isDragActive })}
                        >
                            <input {...getInputProps()} />
                            {header}
                            <Preview
                                asset={this.asset}
                                onRemove={this.onRemove}
                            />
                        </DropZoneContent>

                    )}
                </Dropzone>
            </AssetWrapper>
        );
    }

}


// <div>
// {header}
// {this.preview()}
// </div>
