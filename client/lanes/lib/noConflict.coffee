
`
var previousLanes = window.Lanes;

if (!Lanes){
    window.Lanes = Lanes = {};
}

Lanes.noConflict = function(){
    Lanes.$ = window.jQuery.noConflict(true);
    window.Lanes = previousLanes;
    return Lanes;
};

`
