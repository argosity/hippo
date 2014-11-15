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

            def assets_for_directory(directory)
                path = "skr/screens/#{directory.basename}"
                assets = []
                unless Pathname.glob([ directory.join('*.js'), directory.join('*.coffee')] ).empty?
                    assets << "#{path}.js"
                end
                unless Pathname.glob([ directory.join('*.css'), directory.join('*.scss')] ).empty?
                    assets << "#{path}.css"
                end
                assets
            end

            # def groups(sprockets)
            #     groups = []
            #     each_definition(sprockets) do | spec |
            #         unless groups.detect{ |group| group['id'] == spec.group_id }
            #             groups << spec.group_definition
            #         end
            #         groups
            #     end
            # end

            # def each_definition(sprockets)
            #     ScreenDefinition.each(sprockets) do | definition |
            #         spec = definition.specification
            #         spec['files'] = definition.asset_file_names.map{ |file| "/assets/#{file}" }
            #         yield spec
            #     end
            # end
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
                    files: files,
                    group_id: group_id,
                    description: description
                }, mode: :compat)
            end
        end

        class SystemGroup < Group
            identifier  "system-settings"
            title       "System Settings"
            description "Modify system settings"
            icon        "icon-wrench"
        end

        class UserMaintScreen < Definition
            identifier  "user-maintenance"
            title       "User Maintenance"
            description "Add/Remove/Modify User Accounts"
            icon        "icon-group"
            group_id    "system-settings"
            model_class "User"
            view_class  "UserManagement"
            files       ['/assets/user-management.js','/assets/user-management.css']
        end

    end

end
