require 'guard/compat/plugin'
require_relative 'api'

module ::Guard

    class HippoGuardPlugin
        ROOT = Pathname.new(__FILE__).dirname.join('..','..')

        attr_reader :threads, :jest, :webpack

        def initialize(options = {})

            super

        end

        def stop
            webpack.stop
            jest.stop
            threads.each do |thread|
                thread.exit
            end

        end

        def start
            @threads = Array.new()

            @webpack = WebpackDriver::DevServer.new(
                '--port', '8889', '--config',
                ROOT.join('lib','js','webpack.config.js').expand_path.to_s
            )
            Hippo::API.webpack = @webpack

            roots = Hippo::Extensions.map{|ext| ext.root_path.join('client').to_s }

            @jest = ::ChildProcess.build(
                ROOT.join('node_modules/jest-cli/bin/jest.js').to_s, '--watch',
                '--config', ROOT.join('lib', 'js', 'jest.config.js').to_s
            )

            @jest_output, w = IO.pipe
            jest.io.stdout = jest.io.stderr = w
            # jest.io.stdin = STDIN
            jest.start
            Thread.new do
                @jest_output.each_line do | l |
                    puts l
                end
            end

            threads << Thread.new {
                Hippo::API::Root.run!
            }
            threads << Thread.new {
                until API::Root.running?
                    sleep 1
                end
                # needed to remove the Sinatra's handler
                trap("INT") { exit }
            }


            webpack.environment.merge!(
                HIPPO_EXT_ROOTS: roots.join(',')
            )

            webpack.start

            sleep(1)

            unless webpack.alive?
                puts webpack.messages
            end

        end

    end

end
