class Lanes.Components.AssetsListing extends Lanes.React.Component

    propTypes:
        assets: Lanes.PropTypes.Collection.isRequired
        size: React.PropTypes.oneOf([
            'thumb', 'medium', 'original'
        ]).isRequired

    modelBindings:
        assets: 'props'

    render: ->
        <div className="assets-listing">
            {@assets.map (asset) ->
                <LC.ImageAsset key={asset.cid}
                    asset={asset} size="thumb" />}
        </div>
