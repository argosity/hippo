//= require ./namespace

// https://pie.gd/test/script-link-events/

(function( w ){
    var insertBefore = function(){
        var refs = doc.getElementsByTagName( "head" )[ 0 ].childNodes;
        return refs[ refs.length - 1];
    };

    var doc = w.document;

    // https://github.com/filamentgroup/loadJS/blob/master/loadJS.js
    var loadJS = function( src, cb ){
        "use strict";
        var ref = insertBefore();
        var script = doc.createElement( "script" );
        script.src = src;
        script.async = true;
        ref.parentNode.insertBefore( script, ref );
        if (cb && typeof(cb) === "function") {
            script.onload = function(ev){
                cb(script, ev);
            }
        }
        return script;
    };


    // https://github.com/filamentgroup/loadCSS/blob/master/src/loadCSS.js
    var loadCSS = function( href, cb){
        var ss = doc.createElement( "link" );
        var ref = insertBefore();

        var sheets = doc.styleSheets;
        ss.rel = "stylesheet";
        ss.href = href;
        ss.media = "only x";

        // wait until body is defined before injecting link. This ensures a non-blocking load in IE11.
        function ready( cb ){
            if( doc.body ){
                return cb();
            }
            setTimeout(function(){
                ready( cb );
            });
        }
        // Inject link
        // Note: the ternary preserves the existing behavior of "before" argument, but we could choose to change the argument to "after" in a later release and standardize on ref.nextSibling for all refs
        // Note: `insertBefore` is used instead of `appendChild`, for safety re: http://www.paulirish.com/2011/surefire-dom-element-insertion/
        ready( function(){
            ref.parentNode.insertBefore( ss, ref.nextSibling );
        });
        // A method (exposed on return object for external use) that mimics onload by polling document.styleSheets until it includes the new sheet.
        var onloadcssdefined = function( cb ){
            var resolvedHref = ss.href;
            var i = sheets.length;
            while( i-- ){
                if( sheets[ i ].href === resolvedHref ){
                    return cb(sheets[i]);
                }
            }
            setTimeout(function() {
                onloadcssdefined( cb );
            });
        };

        function loadCB(ev){
            if( ss.addEventListener ){
                ss.removeEventListener( "load", loadCB );
            }
            ss.media = "all";
            if (cb && typeof(cb) === "function") {
                cb(ss, ev);
            }
        }

        // once loaded, set link's media back to `all` so that the stylesheet applies once it loads
        if( ss.addEventListener ){
            ss.addEventListener( "load", loadCB);
        } else {
            onloadcssdefined( loadCB );
        }
        return ss;
    };

    w.Lanes.lib.loader = {
        js: loadJS,
        css: loadCSS
    };

}( typeof global !== "undefined" ? global : this ));
