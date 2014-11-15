var Lanes = ( global.Lanes || (global.Lanes = {}) );

Lanes.Vendor = ( Lanes.Vendor || {} );

Lanes.Vendor.Ampersand                = ( Lanes.Ampersand || {} );
Lanes.Vendor.Ampersand.View           = require("ampersand-view");
Lanes.Vendor.Ampersand.State          = require("ampersand-state");
Lanes.Vendor.Ampersand.CollectionView = require("ampersand-collection-view");
Lanes.Vendor.Ampersand.SubCollection  = require("ampersand-subcollection");
Lanes.Vendor.Ampersand.RestCollection = require("ampersand-rest-collection");
Lanes.Vendor.Ampersand.USCollection   = require('ampersand-collection-underscore-mixin');
Lanes.Vendor.Ampersand.Collection     = require("ampersand-collection");
Lanes.Vendor.Ampersand.Model          = require("ampersand-model");
Lanes.Vendor.Ampersand.Router         = require("ampersand-router");
Lanes.Vendor.AmpersandFormView        = require("ampersand-form-view");
Lanes.Vendor.AmpersandInputView       = require("ampersand-input-view");
Lanes.Vendor.KeyMaster                = require("keymaster");
Lanes.Vendor.Moment                   = require("moment");
Lanes.Vendor.RSVP                     = require('rsvp');
Lanes.Promise                         = Lanes.Vendor.RSVP.Promise;
Lanes.Deferred                        = Lanes.Vendor.RSVP.defer;


var u        = require('underscore');
var spf      = require('sprintf-js');

u.getPath    = require('get-object-path');
u.bigDecimal = require('big.js');
u.dom        = require('ampersand-dom');
u.sprintf    = spf.sprintf;
u.vsprintf   = spf.vsprintf;

global._ = u;
