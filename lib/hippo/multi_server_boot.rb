module Hippo
    module MultiServiceBoot
        def self.perform
            require 'hippo/api'
            Hippo::Configuration.apply

            config = Hippo::Command::ClientConfig.new
            config.invoke_all

            API.webpack = Hippo::Command::Webpack.new([], wait: false)
            API.webpack.config = config

            API.webpack.invoke_all# startup

            Hippo::GuardTasks.client_config = config

            sleep(1) # give webpack a bit of time to fail if it's going to
            unless API.webpack.process.alive?
                puts API.webpack.messages
                exit 1
            end
            Guard.start # will block until complete
            API.webpack.process.stop # stop webpack after guard completes
        end
    end
end
