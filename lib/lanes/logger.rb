# -*- coding: utf-8 -*-
require 'logger'

module Lanes

    class MultiDestinationLogger
        def initialize
            @targets = [
                STDOUT,
                File.open("log/#{Lanes.config.environment}.log", "a")
            ]
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
            @logger ||= (
                if defined?(::Rails)
                    Rails.logger
                else
                    if Lanes.env.production?
                        dest = if FileTest.writable?("log/production.log")
                                   "log/production.log"
                               else
                                   STDOUT
                               end
                        ::Logger.new(dest)
                    else
                        ::Logger.new MultiDestinationLogger.new
                    end
                end
            )
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

    end

    Lanes.config.get(:environment) do | env |
        self.logger=nil # it'll be re-opened on next write
    end

end
