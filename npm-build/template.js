var Lanes = ( global.Lanes || (global.Lanes = {}) );

Lanes.Vendor = ( Lanes.Vendor || {} );

Lanes.Vendor.Ampersand                = ( Lanes.Ampersand || {} );
Lanes.Vendor.Ampersand.Bindings       = require("ampersand-dom-bindings");
Lanes.Vendor.Ampersand.State          = require("ampersand-state");
Lanes.Vendor.Ampersand.CollectionView = require("ampersand-collection-view");
Lanes.Vendor.Ampersand.SubCollection  = require("ampersand-subcollection");
Lanes.Vendor.Ampersand.RestCollection = require("ampersand-rest-collection");
Lanes.Vendor.Ampersand.USCollection   = require('ampersand-collection-underscore-mixin');
Lanes.Vendor.Ampersand.Collection     = require("ampersand-collection");
Lanes.Vendor.Ampersand.Model          = require("ampersand-model");
Lanes.Vendor.Ampersand.Router         = require("ampersand-router");
Lanes.Vendor.KeyMaster                = require("keymaster");
Lanes.Vendor.Moment                   = require("moment");
Lanes.Vendor.RSVP                     = require('rsvp');
Lanes.Vendor.domify                   = require('domify');
Lanes.Vendor.BBEvents                 = require('backbone-events-standalone');

var u        = require('underscore');
var spf      = require('sprintf-js');

u.Promise         = Lanes.Vendor.RSVP.Promise;
u.DeferredPromise = Lanes.Vendor.RSVP.defer;

u.getPath    = require('get-object-path');
u.bigDecimal = require('big.js');
u.dom        = require('ampersand-dom');
u.sprintf    = spf.sprintf;
u.vsprintf   = spf.vsprintf;

global._ = u;
