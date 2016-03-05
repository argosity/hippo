var Lanes = ( global.Lanes || (global.Lanes = {}) );
Lanes.Vendor = ( Lanes.Vendor || {} );

Lanes.Vendor.ReactWidgets = require('react-widgets')
require("./react-widgets.less");
var Moment = require('moment');
var momentLocalizer = require('react-widgets/lib/localizers/moment');
momentLocalizer(Moment);

var numberLocalizer = require('react-widgets/lib/localizers/simple-number')
numberLocalizer();
