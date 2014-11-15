# -*- coding: utf-8 -*-
require 'logger'

module Lanes

    class << self
        def logger
            @logger ||= (
              if defined?(::Rails)
                  Rails.logger
              else
                  Logger.new(STDOUT)
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
end
