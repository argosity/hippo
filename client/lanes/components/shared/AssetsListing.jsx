import React from 'react';

import PropTypes from 'prop-types';

export class AssetsListing extends React.Component {
    static propTypes = {
        assets: Lanes.PropTypes.Collection.isRequired,
        size: PropTypes.oneOf([
            'thumb', 'medium', 'original'
        ]).isRequired
    };

    static modelBindings =
        {assets: 'props'};
    render() {
        return (
            <div export className="assets-listing">
                {this.assets.map(asset =>
                        <LC.ImageAsset key={asset.cid} asset={asset} size="thumb" />)}
            </div>
        );
    }
}
