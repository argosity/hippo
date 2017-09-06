import React from 'react';
import PropTypes from 'prop-types';
import { action, observable, toJS } from 'mobx';
import { isEmpty } from 'lodash';
import { observer, Provider, PropTypes as MobxPropTypes } from 'mobx-react';

// The editor core
import Editor, { Editable, createEmptyState } from 'ory-editor-core';

// Require our ui components (optional). You can implement and use your own ui too!
import { Trash, Toolbar } from 'ory-editor-ui';
import 'ory-editor-ui/lib/index.css';
import 'ory-editor-core/lib/index.css';

import { plugins, defaultPlugin } from './text-editor/plugins';
import DisplayModeToggle from './text-editor/display-modes';
import './text-editor/text-editor.scss';

const editorInstance = new Editor({
    plugins,
    editables: [createEmptyState()],
    defaultPlugin,
});

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
        editorInstance.trigger.editable.add(this.content);
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
                        editor={editorInstance}
                        onSave={this.onSave}
                    >
                        {this.props.children}
                    </DisplayModeToggle>
                    <div className="text-editor-content">
                        <Editable
                            editor={editorInstance}
                            id={this.content.id}
                            onAddImage={this.props.onAddImage}
                            onChange={this.onEditStateChange}
                        />
                    </div>
                    <Trash editor={editorInstance}/>
                    <Toolbar editor={editorInstance} />
                </div>

            </Provider>
        );
    }
}
