var Lanes = ( global.Lanes || (global.Lanes = {}) );
Lanes.Vendor = ( Lanes.Vendor || {} );

Lanes.Vendor.Dayz = require("dayz").default;

require("file?name=calendar.scss!dayz/style/dayz.scss");