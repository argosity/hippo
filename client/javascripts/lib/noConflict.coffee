
`
var previousLanes = window.Lanes;

if (!Lanes){
    window.Lanes = Lanes = {};
}

Lanes.noConflict = function(){
    window.Lanes = previousLanes;
    return Lanes;
};

`
