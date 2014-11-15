require 'pathname'
require 'yaml'

module Lanes
    module DB

        class Seed

            @@seeds = []

            class << self

                def add(&block)
                    @@seeds.push(block)
                end

                # Loads the database with seed models
                def execute!
                    @@seeds.each(&:call)
                end

            end

        end

    end
end
