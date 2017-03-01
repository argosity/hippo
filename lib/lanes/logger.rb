# -*- coding: utf-8 -*-
require 'logger'

module Lanes

    class MultiDestinationLogger
        def initialize
            @targets = [STDOUT]
            @targets.push(
                File.open("log/#{Lanes.config.environment}.log", "a")
            ) if File.writable?("log")
            Lanes.config.get(:environment) do
                @targets.each{|t| t.sync = ! Lanes.env.production? }
            end
        end

        def write(*args)
            @targets.each {|t| t.write(*args)}
        end

        def close
            @targets.each(&:close)
        end

    end

    class << self
        def logger
            @logger ||= _create_logger
        end

        def logger=( logger )
            @logger = logger
        end

        def silence_logs( &block )
            old_logger = Lanes.logger
            begin
                Lanes.logger=Logger.new( StringIO.new )
                yield
            ensure
                Lanes.logger=old_logger
            end
        end

        def logger_debug( output )
            logger.debug '⚡ '*40
            logger.debug '⚡ ' + output
            logger.debug '⚡ '*40
        end

        private

        def _create_logger

            if defined?(::Rails)
                # Rails.logger
            else
                # if Lanes.env.production?
                #     dest = if FileTest.writable?("log/production.log")
                #                "log/production.log"
                #            else
                #                STDOUT
                #            end
                #     logger = ::Logger.new(dest)
                #     logger.level = ::Logger::WARN
                #     logger
                # else

                    logger = ::Logger.new MultiDestinationLogger.new
                    logger.formatter = proc do |severity, datetime, progname, msg|
                        sprintf "%5.5s %s\n", severity, msg
                    end

                    # logger.formatter = proc do |severity, datetime, progname, msg|
                    #     # sprintf "%5.5s %s\n", severity, msg
                    # end

#                    original_formatter = Logger::Formatter.new
                    # logger.formatter = proc { |severity, datetime, progname, msg|
                    #     original_formatter.call(severity, datetime, progname, msg.dump)
                    # }

                    logger.level = ::Logger::INFO
                    logger
                # end
            end
        end


    end


end
