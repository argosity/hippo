var Lanes = ( global.Lanes || (global.Lanes = {}) );
Lanes.Vendor = ( Lanes.Vendor || {} );

Lanes.Vendor.Ampersand                = ( Lanes.Ampersand || {} );
Lanes.Vendor.Ampersand.State          = require("ampersand-state");
Lanes.Vendor.React                    = require("react");

Lanes.Vendor.Ampersand.SubCollection  = require("ampersand-subcollection");
Lanes.Vendor.Ampersand.RestCollection = require("ampersand-rest-collection");
Lanes.Vendor.Ampersand.USCollection   = require('ampersand-collection-underscore-mixin');
Lanes.Vendor.Ampersand.Collection     = require("ampersand-collection");
Lanes.Vendor.ReactBootstrap           = require("react-bootstrap");
Lanes.Vendor.ReactRouter              = require("react-router");
Lanes.Vendor.Moment                   = require("moment");
Lanes.Vendor.RSVP                     = require('rsvp');
Lanes.Vendor.BBEvents                 = require('backbone-events-standalone');
Lanes.Vendor.xhr                      = require('xhr');


Lanes.Vendor.ld = require('lodash');
var spf = require('sprintf-js');

Lanes.Vendor.ld.mixin(require('underscore.inflection'));
Lanes.Vendor.s = require('underscore.string');
_.mixin(Lanes.Vendor.s.exports());
Lanes.Vendor.ld.mixin({
    Promise         : Lanes.Vendor.RSVP.Promise,
    getPath         : require('get-object-path'),
    bigDecimal      : require('big.js'),
    sorty           : require('sorty'),
    classnames      : require('classnames')
});

Lanes.Vendor.dom = require('ampersand-dom');
