Lanes.Data.Bootstrap = {

    initialize: (options)->
        Lanes.Data.Config.csrf_token = options.csrf
        Lanes.Data.Config.api_path  = options.api_path
        Lanes.Extensions.setBootstrapData(options);

}
