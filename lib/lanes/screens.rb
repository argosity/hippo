require 'yaml'

module Lanes

    module Screens
        class << self

            def each_directory
                root = Pathname.new(__FILE__).dirname.join('../../assets/screens')
                root.each_child do | path  |
                    yield path if path.directory?
                end
            end

        end

        class Group
            include Concerns::AttrAccessorWithDefault

            attr_accessor_with_default :identifier
            attr_accessor_with_default :title
            attr_accessor_with_default :description
            attr_accessor_with_default :icon

            def self.each(config)
                self.descendants.each{ |klass| yield klass.new(config) }
            end

            def initialize(sprockets)
                @sprockets=sprockets
            end

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
            attr_accessor_with_default :view_class
            attr_accessor_with_default :model_class
            attr_accessor_with_default :files

            def self.each(config)
                self.descendants.each{ |klass| yield klass.new(config) }
            end

            def initialize(sprockets)
                @sprockets=sprockets
            end

            def to_json
                Oj.dump({
                    id:    identifier,
                    title: title,
                    icon:  icon,
                    model: model_class,
                    view:  view_class,
                    files: files.map{ |f| "#{Lanes.config.assets_path_prefix}/#{f}"},
                    group_id: group_id,
                    description: description
                }, mode: :compat)
            end
        end

    end

end
