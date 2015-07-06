var Lanes = ( global.Lanes || (global.Lanes = {}) );
Lanes.Vendor = ( Lanes.Vendor || {} );
if (! Object.assign){
    Object.assign = require('object-assign');
}
Lanes.Vendor.React = require("react");
var FDT = require('fixed-data-table');
Lanes.Vendor.Grid  = FDT.Table;
Lanes.Vendor.Grid.Column  = FDT.Column;

require("fixed-data-table/dist/fixed-data-table.css");
