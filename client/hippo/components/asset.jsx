import React from 'react';
import PropTypes from 'prop-types';
import { Col } from 'react-flexbox-grid';
import { action } from 'mobx';
import { observer }   from 'mobx-react';
import { titleize } from 'hippo/lib/util';
import classnames from 'classnames';
import Dropzone from 'react-dropzone';

import Field from 'grommet/components/FormField';
import { Document } from 'grommet-icons';

import { BaseModel } from '../models/base';
import './asset.scss';

@observer
export default class Asset extends React.Component {

    static defaultProps = {
        label: '',
        className: '',
        tabIndex: 0,
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
            model: _, label: __, name: ___, className, tabIndex, ...col
        } = this.props;

        return (
            <Col
                {...col}
                className={classnames(className, 'asset', 'form-field')}
            >
                <Field
                    label={this.label}
                    tabIndex={tabIndex}
                    onKeyPress={this.onKey}
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
                </Field>
            </Col>
        );
    }

}
