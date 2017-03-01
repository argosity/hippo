require_relative "../lanes"
# require 'guard/jasmine'
require "guard/jest"
require 'guard/minitest'
require "net/http"
require "uri"
# require_relative "lanes_guard_plugin"

# require_relative "hot_reload_plugin"
require_relative 'command/jest'

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
        end


        def self.run(dsl, options, &block)
            app_name = options[:name] || Pathname.getwd.basename.to_s
            matchers = CustomMatchers.new
            yield matchers

            jest_options = options.merge(
                logger: Lanes.logger,
                silent: false,
                jest_cmd: './node_modules/.bin/jest',
                config_file: ::Lanes::Command::Jest.new.configure.config_file
            )

            dsl.guard :jest, jest_options


            minitest_options = {
              all_on_start: false, test_folders: 'spec/server'
            }
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
