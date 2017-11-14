module Hippo

    module Screen

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
            attr_accessor_with_default :roles, ->{ [] }
            attr_accessor_with_default :asset

            attr_accessor :extension_id

            def initialize(id, extension_id)
                self.identifier = id
                @extension_id = extension_id
                @extension    = extension_id.underscore.camelize
            end

            def group
                GROUPS[@group_id]
            end

            def has_file_matching?(pattern)
                Pathname.glob(root_path.join(pattern)).any?
            end

            def root_path
                ext = Hippo::Extensions.for_identifier(@extension_id)
                raise "Unable to find extension '#{@extension_id}' for screen group" unless ext
                ext.root_path.join('client', url_prefix, identifier)
            end

            def model
                return nil if @model_class.blank?
                @model_class.safe_constantize || (@extension_id.camelize + '::' + @model_class).safe_constantize
            end

            def viewable_by?(user)
                if roles.present?
                    return (roles & user.role_names).any?
                end
                model.nil? || user.can_read?(self)
            end

            def asset_path
                (asset && asset =~ /\//) ? asset : "#{@extension_id}/screens/#{asset || identifier}"
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
                    asset: asset_path
                }
            end

            def to_json
                Oj.dump(as_json, mode: :compat)
            end
        end

    end

end
