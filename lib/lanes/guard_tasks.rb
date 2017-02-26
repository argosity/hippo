require_relative "../lanes"
# require 'guard/jasmine'
require "guard/jest"
require 'guard/minitest'
require "net/http"
require "uri"
# require_relative "lanes_guard_plugin"

# require_relative "hot_reload_plugin"

module Lanes
    module GuardTasks

        class CustomMatchers
            attr_reader :client_matches, :server_matches#, :hot_reload

            def client(&block)
                @client_matches = block
            end
            def server(&block)
                @server_matches = block
            end
            # def lanes_plugin(&block)
            #     @hot_reload = block
            # end
        end


        def self.run(dsl, options, &block)
            app_name = options[:name] || Pathname.getwd.basename.to_s
            matchers = CustomMatchers.new
            yield matchers


            minitest_options = {
              all_on_start: false, test_folders: 'spec/server'
            }

            jest_options = options.merge(
                silent: false,
                jest_cmd: './node_modules/jest-cli/bin/jest.js',
                config_file:'./lib/js/jest.config.js'
            )

            # coffee_files = %r{^client/(.+?)\.(js|coffee|cjsx)$}

#            dsl.guard :lanes_guard_plugin



            dsl.guard :jest, jest_options do
                # dsl.watch(%r{client/lanes/(.+?)\.(js|jsx)$}) do |m|
                #     "spec/client/#{m[1]}.spec.#{m[2]}"
                # end
#                matchers.client_matches.call if matchers.client_matches
            end

            dsl.guard :minitest, minitest_options do
                dsl.watch(%r{^spec/server/spec_helper\.rb}) { 'test' }
                dsl.watch(%r{^spec/server/.*_spec\.rb})
                dsl.watch(%r{^spec/fixtures/#{app_name}/(.+)s\.yml})   { |m| "spec/server/#{m[1]}_spec.rb" }
                dsl.watch(%r{^lib/#{app_name}/(.+)\.rb})               { |m| "spec/server/#{m[1]}_spec.rb" }
                matchers.server_matches.call if matchers.server_matches
            end

        end

    end
end
