var Lanes = ( global.Lanes || (global.Lanes = {}) );
Lanes.Vendor = ( Lanes.Vendor || {} );
if (! Object.assign){
    Object.assign = require('object-assign');
}

Lanes.Vendor.Grid  = require("react-datagrid");

require("react-datagrid/index-no-normalize.css");
