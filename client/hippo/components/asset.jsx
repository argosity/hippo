import React from 'react';
import PropTypes from 'prop-types';
import { Col } from 'react-flexbox-grid';
import { action } from 'mobx';
import { observer }   from 'mobx-react';
import { titleize } from 'hippo/lib/util';
import classnames from 'classnames';
import Dropzone from 'react-dropzone';

import Field from 'grommet/components/FormField';
import DocumentIcon from 'grommet/components/icons/base/DocumentCloud';

import { BaseModel } from '../models/base';
import './asset.scss';

@observer
export default class Asset extends React.PureComponent {

    static defaultProps = {
        label: '',
        className: '',
    }

    static propTypes = {
        model:   PropTypes.instanceOf(BaseModel).isRequired,
        name: PropTypes.string.isRequired,
        label:    PropTypes.string,
        className: PropTypes.string,
    }

    @action.bound
    onDrop(files) {
        if (!this.asset) {
            this.props.model[this.props.name] = {};
        }
        this.asset.file = files[0];
    }

    get asset() {
        return this.props.model[this.props.name];
    }

    get label() {
        return this.props.label || titleize(this.props.name);
    }

    preview() {
        if (this.asset) {
            return this.asset.isImage ?
                <img src={this.asset.previewUrl} alt="" /> :
                <DocumentIcon size="xlarge" type="status" />;
        }
        return (
            <div>
                Drop a file here, or click to select one to upload.
            </div>
        );
    }

    render() {
        const { model: _, label: __, name: ___, className, ...col } = this.props;

        return (
            <Col
                {...col}
                className={classnames(className, 'asset', 'form-field')}
            >
                <Field label={this.label} >
                    <Dropzone
                        className="drop-zone"
                        activeClassName="drop-zone-active"
                        onDrop={this.onDrop}
                        multiple={false}
                    >
                        {this.preview()}
                    </Dropzone>
                </Field>
            </Col>
        );
    }
}
