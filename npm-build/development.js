var Lanes = ( global.Lanes || (global.Lanes = {}) );
Lanes.Vendor = ( Lanes.Vendor || {} );
var React = require('react/addons');
Lanes.Vendor.ReactTestUtils = React.addons.TestUtils;
Lanes.Vendor.hotRL = require('react-hot-api')(function () {
    return require('react/lib/ReactMount')._instancesByReactRootID;
});
