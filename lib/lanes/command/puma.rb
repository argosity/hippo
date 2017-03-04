require_relative '../extension'
require_relative '../command'

require 'irb'

module Lanes
    module Command

        class Puma < Thor::Group
            include Thor::Actions

            class_option :wait, :type => :boolean, default: true,
                         desc: "Whether to keep running and wait for exit"

            def start
                say "Starting Puma", :green
                @proc = ::ChildProcess.build('puma')
                @output, w = IO.pipe
                @proc.io.stdout = @proc.io.stderr = w
                @proc.start
                w.close
                @listener = listen_for_status_updates
                sleep 1
                unless @proc.alive?
                    raise "NOT LIVING"
                    puts @output.read
                end
                self
            end

            def maybe_wait
                @proc.wait if options[:wait]
            end

            def stop
                say "Stopping Puma", :green
                @listener.kill
                @proc.stop
                @prop = nil
            end

            private


            def listen_for_status_updates
                Thread.new do
                    @output.each_line do | l |
                        Lanes.logger.info(l.chomp)
                    end
                end
            end


        end
    end
end
