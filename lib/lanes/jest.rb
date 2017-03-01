require 'forwardable'
require 'erb'

module Lanes
    class Jest
        attr_reader :config_dir

        def self.launch
            puts 'Jest'
            @config_dir = Pathname.new(Dir.mktmpdir)

            template config_dir.join('jest.config'),    "#{client_dir}/screens/#{screen_id}/index.js"

            puts Dir.glob(config_dir + '*')
        end

    end

end
