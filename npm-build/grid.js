var Lanes = ( global.Lanes || (global.Lanes = {}) );
Lanes.Vendor = ( Lanes.Vendor || {} );
if (! Object.assign){
    Object.assign = require('object-assign');
}
Lanes.Vendor.React = require("react");
Lanes.Vendor.Grid  = require("react-datagrid");
