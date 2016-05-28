var previousLanes = global.Lanes;

var Lanes = ( global.Lanes || (global.Lanes = {}) );

Lanes.noConflict = function(){
    global.Lanes = previousLanes;
    return Lanes;
};

Lanes.Vendor = ( Lanes.Vendor || {} );
Lanes.Vendor.xhr = require('xhr');
Lanes.Vendor.ld = require('lodash');

Lanes.Vendor.Ampersand                = ( Lanes.Ampersand || {} );
Lanes.Vendor.Ampersand.State          = require("ampersand-state");

Lanes.Vendor.Ampersand.SubCollection  = require("ampersand-filtered-subcollection");
Lanes.Vendor.Ampersand.RestCollection = require("ampersand-rest-collection");
Lanes.Vendor.Ampersand.LDCollection   = require('ampersand-collection-lodash-mixin');
Lanes.Vendor.Ampersand.Collection     = require("ampersand-collection");
Lanes.Vendor.Events                   = require('ampersand-events');

Lanes.log           = require('loglevel');
Lanes.Vendor.dom    = require('ampersand-dom');
Lanes.Vendor.Moment = require("moment");
Lanes.Vendor.RSVP   = require('rsvp');

var spf = require('sprintf-js');

Lanes.Vendor.ld.mixin(require('lodash-inflection'));

Lanes.Vendor.s = require('underscore.string');
_.mixin(Lanes.Vendor.s.exports());

_.moment = Lanes.Vendor.Moment;
require('moment-range')

Lanes.Vendor.ld.mixin({
    Promise         : Lanes.Vendor.RSVP.Promise,
    getPath         : require('get-object-path'),
    bigDecimal      : require('big.js'),
    sorty           : require('sorty'),
    classnames      : require('classnames'),
    sprintf         : spf.sprintf,
    vsprintf        : spf.vsprintf
});
