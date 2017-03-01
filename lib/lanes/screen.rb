require 'yaml'
require 'oj'
require 'pry'

module Lanes

    module Screen

        GROUPS=Hash.new{|h,k| g=Group.new; g.identifier=k; h[k]=g }
        DEFINITIONS=Hash.new #{|h,k| d=Definition.new; d.identifier=k; h[k]=d }

        class DefinitionList
            def initialize(extension_id)
                @extension_id = extension_id
            end

            def define(id)
                definition = ( DEFINITIONS[id] ||= Definition.new(id, @extension_id) )
                yield definition
            end
        end

        class << self
            def [](config)
                if DEFINITIONS.has_key?(config)
                    DEFINITIONS[config]
                else
                    nil
                end
            end

            def for_extension(id)
                yield DefinitionList.new(id)
            end

            def define_group(id)
                group = GROUPS[id]
                yield group
            end

            def each
                Extensions.load_screens
                DEFINITIONS.values.each{ | definition | yield definition }
            end

            def each_group
                Extensions.load_screens
                GROUPS.values.each{ | group | yield group }
            end

            def config_file
                Lanes::Extensions.controlling.root_path.join("config","screens.rb")
            end

            def uncache_file_on_update(asset)
                asset.depend_on(config_file) if config_file.exist?
            end
        end


        class Group
            include Concerns::AttrAccessorWithDefault

            attr_accessor_with_default :identifier
            attr_accessor_with_default :title
            attr_accessor_with_default :description
            attr_accessor_with_default :icon

            def to_json
                Oj.dump({
                    id: identifier,
                    title: title,
                    description: description,
                    icon: icon
                }, mode: :compat)
            end
        end

        class Definition
            include Concerns::AttrAccessorWithDefault

            attr_accessor_with_default :identifier
            attr_accessor_with_default :title
            attr_accessor_with_default :description
            attr_accessor_with_default :icon
            attr_accessor_with_default :group_id
            attr_accessor_with_default :extension
            attr_accessor_with_default :view_class
            attr_accessor_with_default :model_class
            attr_accessor_with_default :model_access, 'read'
            attr_accessor_with_default :asset

            def initialize(id, extension_id)
                self.identifier = id
                @extension_id = extension_id
                @extension    = extension_id.underscore.camelize
            end

            def has_file_matching?(pattern)
                Pathname.glob(root_path.join(pattern)).any?
            end

            def root_path
                ext = Lanes::Extensions.for_identifier(@extension_id)
                raise "Unable to find extension '#{@extension_id}' for screen group" unless ext
                ext.root_path.join('client', url_prefix, identifier)
            end

            def as_json
                {
                    id:    identifier,
                    title: title,
                    icon:  icon,
                    model: model_class,
                    view:  view_class,
                    access: model_access,
                    group_id: group_id,
                    extension: extension,
                    description: description,
                    asset: asset
                }
            end

            def to_json
                Oj.dump(as_json, mode: :compat)
            end
        end

    end

end
