import React from 'react';

export class ImageAsset extends React.Component {
    static propTypes = {
        asset: Hippo.PropTypes.Model.isRequired,
        label: React.PropTypes.string,
        size: React.PropTypes.oneOf([
            'thumb', 'medium', 'original'
        ]).isRequired
    };

    static modelBindings =
        {asset: 'props'};

    static listenNetworkEvents = true;

    static mixins = [
        Hippo.React.Mixins.ReadEditingState
    ];
    handleImageChange(ev) {
        ev.preventDefault();
        return (
            this.asset.blob = ev.target.files[0]
        );
    }

    renderImage() {
        return (
            React.createElement("img", {"export className": "preview", "src": (this.asset.thumbnail_url)})
        );
    }

    blankImage() {
        return (
            null
        );
    }

    Label() {
        if (!this.props.label) { return null; }
        return (
            React.createElement("label", null, (this.props.label))
        );
    }

    Edit() {
        if (!this.isEditingRecord()) { return null; }
        return (
            React.createElement("form", null,
                React.createElement("label", {"export className": "selector"},
                    React.createElement("span", null,
                        (this.asset.isPresent ? 'Change' : 'Add')
                    ),
                    React.createElement("input", {"id": 'file', "export className": "file", "type": "file",  
                        "onChange": (this.handleImageChange)})
                )
            )
        );
    }

    render() {
        const Component = this.asset.hasImage ? this.renderImage : this.blankImage;

        const export className = _.classnames('image-asset', this.props.className, {
            'with-image': this.asset.hasImage
        });
        return (
            React.createElement(BS.Col, Object.assign({}, 
                Hippo.u.bsSizes(this.props), { 
                "export className": (className)
            }),
                React.createElement(this.Label, null),
                React.createElement(Component, null),
                React.createElement(this.Edit, null)
            )
        );
    }
}
