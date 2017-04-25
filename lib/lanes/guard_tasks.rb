require_relative '../lanes'
require_relative 'command/jest'
require_relative 'reloadable_sinatra.rb'
require 'guard/jest'
require 'guard/rspec'

module Lanes
    module GuardTasks
        mattr_accessor :client_config

        class CustomMatchers
            attr_reader :client_matches, :server_matches

            def client(&block)
                @client_matches = block
            end
            def server(&block)
                @server_matches = block
            end
        end


        def self.run(dsl, options, &block)
            matchers = CustomMatchers.new
            yield matchers
            identifier = ::Lanes::Extensions.controlling.identifier
            config = client_config || ::Lanes::Command::Jest.new.configure.config

            jest_options = options.merge(
                logger: Lanes.logger,
                silent: false,
                jest_cmd: './node_modules/.bin/jest',
                config_file: config.directory.join('jest.config.json')
            )
            dsl.guard :jest, jest_options

            rspec_options = {
                all_on_start: false,
                cmd: 'bundle exec rspec'
            }
            dsl.guard :rspec, rspec_options do
                dsl.watch(%r{^spec/server/spec_helper\.rb}) { 'spec' }
                dsl.watch(%r{^spec/server/.*_spec\.rb})
                dsl.watch(%r{^spec/fixtures/#{identifier}(.+)s\.yml})   { |m| "spec/server/#{m[1]}_spec.rb" }
                dsl.watch(%r{^lib/#{identifier}/(.+)\.rb})              { |m| "spec/server/#{m[1]}_spec.rb" }
                matchers.server_matches.call if matchers.server_matches
            end

            dsl.guard :reloadable_sinatra do
                dsl.watch(%r{^lib/.*\.rb})
                dsl.watch(%r{^config/.*\.rb})
            end
        end

    end
end
