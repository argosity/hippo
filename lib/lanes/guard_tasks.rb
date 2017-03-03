require_relative '../lanes'
require_relative 'command/jest'
require 'guard/jest'
require 'guard/rspec'

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


            rspec_options = {
                all_on_start: false,
                cmd: 'bundle exec rspec'
            }
            dsl.guard :rspec, rspec_options do
#                dsl.watch(%r{^spec/server/spec_helper\.rb}) { 'spec' }
                dsl.watch(%r{^spec/server/.*_spec\.rb})
                # dsl.watch(%r{^spec/fixtures/#{app_name}/(.+)s\.yml})   { |m| "spec/server/#{m[1]}_spec.rb" }
                # dsl.watch(%r{^lib/#{app_name}/(.+)\.rb})               { |m| "spec/server/#{m[1]}_spec.rb" }
                # matchers.server_matches.call if matchers.server_matches
            end

        end

    end
end
