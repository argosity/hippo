require_relative "../appy-app"

module AppyApp

    class Extension < Lanes::Extensions::Definition

        identifier "appy-app"

        title "AppyApp"

        root_path Pathname.new(__FILE__).dirname.join("..","..").expand_path

        # If a data structure that can be represented as JSON
        # is returned from this method, it will be passed to
        # the setBootstrapData method in client/appy-app/Extension.coffee
        # when the app boots
        def client_bootstrap_data
            nil
        end
    end

end
