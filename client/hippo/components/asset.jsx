import React from 'react';
import PropTypes from 'prop-types';
import { action } from 'mobx';
import { observer }   from 'mobx-react';
import { titleize } from 'hippo/lib/util';
import Dropzone from 'react-dropzone';
import color from 'grommet/utils/colors';
import baseTheme from 'grommet/themes/vanilla';
import { Document } from 'grommet-icons';
import { BaseModel } from '../models/base';
import { StyledWrapper } from './form/field-wrapper';

const AssetWrapper = StyledWrapper.withComponent('div').extend`
border-bottom: 0;
.drop-zone { height: 100%; }
padding: ${props => props.theme.global.edgeSize.small};
border: ${props => props.theme.global.borderSize.small} dashed transparent;
overflow: auto;
min-height: 200px;
max-height: 300px;
-webkit-overflow-scrolling: touch;
&:hover {
 border-color: ${props => color.colorForName('light-3', props.theme)};
 cursor: pointer;
 background: ${props => color.colorForName('light-1', props.theme)};
}
`;

@observer
export default class Asset extends React.Component {

    static defaultProps = {
        label: '',
        className: '',
        tabIndex: 0,
        theme: baseTheme,
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

    preview() {
        if (this.asset && this.asset.exists) {
            return this.asset.isImage ?
                <img src={this.asset.previewUrl} alt="" /> :
                <Document size="xlarge" type="status" />;
        }
        return (
            <div>
                Drop a file here, or click to select one to upload.
            </div>
        );
    }


    render() {
        const {
            model: _, label: __, name: ___, tabIndex, height, ...wrapperProps
        } = this.props;

        return (
            <AssetWrapper
                height={height || 3}
                width={3}
                label={this.label}
                tabIndex={tabIndex}
                onKeyPress={this.onKey}
                {...wrapperProps}
            >
                <Dropzone
                    className="drop-zone"
                    activeClassName="drop-zone-active"
                    onDrop={this.onDrop}
                    multiple={false}
                    ref={this.setDZRef}
                >
                    {this.preview()}
                </Dropzone>
            </AssetWrapper>
        );
    }

}
