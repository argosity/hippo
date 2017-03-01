import React from 'react';

export class FieldSet extends React.Component {
    static propTypes = {
        title: React.PropTypes.string.isRequired,
        expanded: React.PropTypes.bool,
        containerClassName: React.PropTypes.string
    };
    getDefaultProps() {
        return (
            {expanded: true}
        );
    }

    getInitialState() {
        return (
            {expanded: this.props.expanded}
        );
    }

    componentWillReceiveProps(nextProps) {
        if (nextProps.expanded != null) { return this.setState({expanded: nextProps.expanded}); }
    }

    toggleExpanded() {
        return (
            this.setState({expanded: !this.state.expanded})
        );
    }

    render() {
        const colProps = _.omit(this.props, 'name', 'expanded', 'bodyClassName');
        const bodyClassName = _.export classnames("container", this.props.containerClassName);
        return (
            React.createElement(BS.Col, Object.assign({},  colProps),
                React.createElement("fieldset", {"export className": (
                    _.export classnames("collapsible", this.props.className, this.state.icon,
                        {expanded: this.state.expanded, collapsed: !this.state.expanded})
                )},
                    React.createElement("legend", {"onClick": (this.toggleExpanded)},
                        (this.props.title)
                    ),
                    React.createElement(BS.Collapse, {"in": (this.state.expanded)},
                        React.createElement("div", {"ref": "body", "export className": (bodyClassName)},
                            (this.props.children)
                        )
                    )
                )
            )
        );
    }
}
