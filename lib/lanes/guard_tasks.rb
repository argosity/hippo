require_relative "../lanes"
require 'guard/jasmine'
require 'guard/minitest'

module Lanes
    module GuardTasks

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
            app_name = options[:name] || Pathname.getwd.basename.to_s
            matchers = CustomMatchers.new
            yield matchers

            jasmine_options = options.merge({
                port: 8888, server_mount: '/spec', server_env: 'test', server: :puma,
                spec_dir: 'spec/client', console: :always, debug: false
            })

            dsl.guard :jasmine, jasmine_options do
                dsl.watch(%r{^client/(.+?)\.(js|coffee)$}){ |m| "spec/client/#{m[1]}_spec.#{m[2]}" }
                dsl.watch(%r{^spec/client/.*(?:_s|S)pec\.coffee$})
                matchers.client_matches.call if matchers.client_matches
            end

            dsl.guard :minitest, :all_on_start => true do
                dsl.watch(%r{^spec/spec_helper\.rb}) { 'test' }
                dsl.watch(%r{^spec/.+_spec\.rb})
                dsl.watch(%r{^spec/fixtures/#{app_name}/(.+)s\.yml})   { |m| "spec/#{m[1]}_spec.rb" }
                dsl.watch(%r{^lib/#{app_name}/(.+)\.rb})               { |m| "spec/#{m[1]}_spec.rb" }
                matchers.server_matches.call if matchers.server_matches
            end

        end

    end
end
