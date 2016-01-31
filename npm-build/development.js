var Lanes = ( global.Lanes || (global.Lanes = {}) );
Lanes.Vendor = ( Lanes.Vendor || {} );

Lanes.Vendor.ReactProxy      = require("react-proxy").default;
Lanes.Vendor.ReactTestUtils  = require('react-addons-test-utils');
Lanes.Vendor.deepForceUpdate = require('react-deep-force-update');
