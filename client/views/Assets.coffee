Lanes.Views.Assets = {
    path: (asset)->
        path = @paths[ asset ]
        Lanes.log( "Path for #{asset} was not found" ) unless path
        path

    setPaths: (paths={})->
        @paths = paths;
}