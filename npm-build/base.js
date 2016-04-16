var Lanes = ( global.Lanes || (global.Lanes = {}) );
Lanes.Vendor = ( Lanes.Vendor || {} );

Lanes.Vendor.Ampersand                = ( Lanes.Ampersand || {} );
Lanes.Vendor.Ampersand.State          = require("ampersand-state");
Lanes.Vendor.React                    = require("react");
Lanes.Vendor.ReactDOM                 = require("react-dom");

Lanes.Vendor.Ampersand.SubCollection  = require("ampersand-subcollection");
Lanes.Vendor.Ampersand.RestCollection = require("ampersand-rest-collection");
Lanes.Vendor.Ampersand.LDCollection   = require('ampersand-collection-lodash-mixin');
Lanes.Vendor.Ampersand.Collection     = require("ampersand-collection");
Lanes.Vendor.Events                   = require('ampersand-events');
Lanes.Vendor.ReactBootstrap           = require("react-bootstrap");
Lanes.Vendor.BrowserHistory           = require("history");
Lanes.Vendor.Moment                   = require("moment");
Lanes.Vendor.RSVP                     = require('rsvp');
Lanes.Vendor.xhr                      = require('xhr');
Lanes.Vendor.ComponentResize          = require('react-component-resizable');
Lanes.Vendor.List                     = require('react-list')
Lanes.Vendor.Overlay = require('react-overlays');
Lanes.log = require('loglevel');
Lanes.Vendor.ld = require('lodash');
var spf = require('sprintf-js');

Lanes.Vendor.React.__spread = Lanes.Vendor.ld.assign;

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

Lanes.Vendor.dom = require('ampersand-dom');
