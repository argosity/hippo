module Lanes
    module Command

        class JestRunner

            attr_reader :proc

            extend Forwardable

            def_delegators :@proc, :alive?, :environment, :wait

            def initialize
                @proc = ::ChildProcess.build(
                    Lanes::ROOT_PATH.join('node_modules/jest-cli/bin/jest.js').to_s,
                    '--watch', '--config',
                    Lanes::ROOT_PATH.join('lib', 'js', 'jest.config.js').to_s
                )
            end

            def stop
                @proc.stop
                @output.close unless @output.closed?
                @listener.exit
            end

            def write(str)
                @proc.io.stdin.write(str + "\n")
                puts "WRote #{str}"
            end

            def start
                @proc.start
                @output, w = IO.pipe
                @proc.io.stdout = @proc.io.stderr = w

                @proc.duplex  = true
                puts "one"
                puts "two"
                @proc.start


                @listener = Thread.new do
                    @output.each_line do | l |
                        Lanes.logger.info l.chomp
                        print "\r"
                    end

#                         # match = l.match(/^STATUS: (.*)/)
#                         # if match
#                         #     record_message(JSON.parse(match[1]))
#                         #    # WebpackDriver.config.logger.debug(l.chomp)
#                         # else
#                         #     WebpackDriver.config.logger.info(l.chomp)
#                         # end
#                     end
                end
            end


        end

    end
end
