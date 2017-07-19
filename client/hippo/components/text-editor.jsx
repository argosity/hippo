import React from 'react';
import PropTypes from 'prop-types';
import { action, observable, toJS } from 'mobx';
import { isEmpty } from 'lodash';
import { observer } from 'mobx-react';
import { Provider, PropTypes as MobxPropTypes } from 'mobx-react';

// The editor core
import Editor, { Editable, createEmptyState } from 'ory-editor-core';

// Require our ui components (optional). You can implement and use your own ui too!
import { Trash, Toolbar } from 'ory-editor-ui';
import tapEventPlugin from 'react-tap-event-plugin';

import { plugins, defaultPlugin } from './text-editor/plugins';

import 'ory-editor-ui/lib/index.css';
import 'ory-editor-core/lib/index.css';

import DisplayModeToggle from './text-editor/display-modes';
import './text-editor/text-editor.scss';


@observer
export default class TextEditor extends React.PureComponent {

    static defaultProps = {
        assets: observable.array(),
    }

    static propTypes = {
        defaultContent: PropTypes.object,
        assets:  MobxPropTypes.observableArray,
        onComplete: PropTypes.func.isRequired,
    }

    componentWillMount() {
        const content = toJS(this.props.defaultContent);
        this.content = isEmpty(content) ? createEmptyState() : content;
        this.editor = new Editor({
            plugins,
            editables: [this.content],
            defaultPlugin,
        });
        tapEventPlugin();
    }

    @action.bound
    onSave() {
        this.props.onComplete({ content: this.content });
    }

    @action.bound
    onEditStateChange(state) {
        this.content = state;
    }

    render() {
        return (
            <Provider
                assets={this.props.assets}
            >
                <div className="text-editor">
                    <DisplayModeToggle
                        editor={this.editor}
                        onSave={this.onSave}
                    >
                        {this.props.children}
                    </DisplayModeToggle>
                    <div className="text-editor-content">
                        <Editable
                            editor={this.editor}
                            id={this.content.id}
                            onAddImage={this.props.onAddImage}
                            onChange={this.onEditStateChange}
                        />
                    </div>
                    <Trash editor={this.editor}/>
                    <Toolbar editor={this.editor} />
                </div>

            </Provider>
        );
    }
}
