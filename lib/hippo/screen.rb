require 'yaml'
require 'oj'
require 'pry'
require_relative 'screen/group'
require_relative 'screen/definition'

module Hippo

    module Screen

        GROUPS=Hash.new{|h,k| g=Group.new; g.identifier=k; h[k]=g }
        DEFINITIONS = Hash.new
        EXTENSIONS  = Hash.new

        mattr_accessor :enabled_group_ids

        class DefinitionList
            attr_reader :ids

            include Enumerable

            def initialize(extension_id)
                @ids = []
                @extension_id = extension_id
            end

            def define(id)
                ids.push(id)
                definition = (DEFINITIONS[id] ||= Definition.new(id, @extension_id))
                yield definition
            end

            def extend(id)
                ids.push(id)
                definition = DEFINITIONS[id]
                definition.extension_id = @extension_id
                yield definition if block_given?
            end

            def each
                ids.each { |id| yield DEFINITIONS[id] }
            end

        end

        class << self
            include Enumerable

            def [](config)
                if DEFINITIONS.key?(config)
                    DEFINITIONS[config]
                else
                    nil
                end
            end

            def each
                DEFINITIONS.values.each { |s| yield s }
            end

            def for_extension(id)
                definition = EXTENSIONS[id] ||= DefinitionList.new(id)
                yield definition if block_given?
                definition
            end

            def define_group(id)
                group = GROUPS[id]
                yield group
            end

            def ids_for_user(user)
                Extensions.load_screens
                for_extension(Hippo::Extensions.controlling.identifier).select{|s|
                    s.viewable_by?(user)
                }.map(&:identifier)
            end

            def each_group
                Extensions.load_screens
                GROUPS.values.each{ | group | yield group }
            end

            def config_file
                Hippo::Extensions.controlling.root_path.join("config", "screens.rb")
            end

        end

    end

end
