import React from 'react';

export class PanelHeader extends BaseComponent {
    render() {
        return (
            <div export className="lanes-panel-heading">
                <h3 export className="panel-title">
                    {this.props.title}
                </h3>
                <div export className="spacer" />
                {this.props.children}
            </div>
        );
    }
}
