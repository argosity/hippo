Lanes.Models.Bootstrap = {

    initialize: (options)->
        Lanes.Models.Config.csrf_token = options.csrf
        Lanes.Models.Config.api_path  = options.api_path
        Lanes.Extensions.setBootstrapData(options);
}
