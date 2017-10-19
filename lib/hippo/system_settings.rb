module Hippo

    class SystemSettings < Hippo::Model
        belongs_to_tenant

        has_one :logo, as: :owner, class_name: 'Hippo::Asset',
                dependent: :destroy

        has_one :print_logo,  -> { where owner_type: "SecondaryPhoto"},
                class_name: 'Hippo::Asset', foreign_key: :owner_id,
                foreign_type: :owner_type,
                dependent: :destroy

        class ExtensionSettings < OpenStruct
            def initialize(ext_id, settings)
                @extension_id = ext_id
                super(settings)
            end
            def persist!
                SystemSettings.persist!(@extension_id, self.to_h)
            end
        end

        after_commit :notify_updated, on: :update
        def notify_updated
            Hippo.redis_connection.publish('hippo-system-configuration-update', self.id)
        end

        def for_ext(extension_id)
            ExtensionSettings.new(extension_id, settings[extension_id.to_s])
        end

        def public_json
            {
                'logo' => Hippo::SystemSettings.config
                              .as_json(include: ['logo'])
                              .dig('logo', 'file_data')
            }
        end

        class << self
            def config
                Tenant.current.system_settings || Tenant.current.create_system_settings
            end

            def public_json
                config.public_json
            end

            def for_ext(extension_id)
                config.for_ext(extension_id)
            end

            def persist!(extension_id, update)
                config.settings[extension_id] = update
                config.settings_will_change!
                config.save!
            end

            def get_handler
                Hippo::API::RequestWrapper.with_authenticated_user(
                    role: 'administrator', with_transaction: false
                ) do |user, req|
                    req.std_api_reply :get,
                                  Hippo::SystemSettings.config.as_json(
                                      include: ['logo', 'print_logo']
                                  )
                end
            end

            def update_handler
                Hippo::API::RequestWrapper.with_authenticated_user(
                    role: 'administrator', with_transaction: false
                ) do |user, req|
                    config = SystemSettings.config
                    if req.data['settings'].is_a?(Hash)
                        config.update_attributes!(settings: req.data['settings'])
                    end
                    req.std_api_reply :update, { settings: config.settings }, success: true
                end
            end

        end
    end
end
