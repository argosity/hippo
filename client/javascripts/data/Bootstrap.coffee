Lanes.Data.Bootstrap = {

    initialize: (options)->
        Lanes.Data.Config.csrf_token = options.csrf
        Lanes.Data.Config.api_path  = options.root
        Lanes.Extensions.setBootstrapData(options.data);

}
