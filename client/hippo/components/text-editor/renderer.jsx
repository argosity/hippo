import React from 'react';
import PropTypes from 'prop-types';
import { plugins } from 'hippo/components/text-editor/plugins';
import { observable, toJS } from 'mobx';
import { observer, Provider, PropTypes as MobxPropTypes } from 'mobx-react';
import { HTMLRenderer } from 'ory-editor-renderer';

import './renderer.scss';

@observer
export default class TextEditorRenderer extends React.Component {

    static defaultProps = {
        assets: observable.array(),
    }

    static propTypes = {
        content: PropTypes.object.isRequired,
        assets:  MobxPropTypes.observableArray,
    }

    static defaultProps = {
        className: PropTypes.string,
    }

    render() {
        return (
            <Provider
                assets={this.props.assets}
            >
                <div className="text-editor-content">
                    <HTMLRenderer
                        className={this.props.className}
                        state={toJS(this.props.content)}
                        plugins={plugins}
                    />
                </div>
            </Provider>
        );
    }

}
