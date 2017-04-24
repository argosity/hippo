module Lanes

    class SystemSettings < Lanes::Model

        has_one :logo, as: :owner, class_name: 'Lanes::Asset',
                dependent: :destroy

        has_one :print_logo,  -> { where owner_type: "SecondaryPhoto"},
                class_name: 'Lanes::Asset', foreign_key: :owner_id,
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
            def apply!
                require 'shrine/storage/file_system'
                ext = Extensions.controlling
                Lanes::Concerns::AssetUploader.storages = {
                    cache: Shrine::Storage::FileSystem.new(ext.root_path,
                                                           prefix: "tmp/cache"),
                    store: Shrine::Storage::FileSystem.new(ext.root_path,
                                                           prefix: "public/files")
                }
            end
        end

        after_commit :notify_updated
        def notify_updated
            Lanes.redis_connection.publish('lanes-system-configuration-update', self.id)
        end

        def for_ext(extension_id)
            ExtensionSettings.new(extension_id, settings[extension_id.to_s])
        end

        class << self
            def config
                @config ||= SystemSettings.find_or_create_by(configuration_id: Lanes.config.configuration_id)
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

                Lanes::API::RequestWrapper.with_authenticated_user(
                    role: 'administrator', with_transaction: false
                ) do |user, req|
                    req.std_api_reply :get,
                                  Lanes::SystemSettings.config.as_json(
                                      include: ['logo', 'print_logo']
                                  )
                end
            end

            def update_handler

                Lanes::API::RequestWrapper.with_authenticated_user(
                    role: 'administrator', with_transaction: false
                ) do |user, req|
                    #                    wrap_reply do
                    config = SystemSettings.config
                    if req.data['settings'].is_a?(Hash)
                        config.update_attributes!(settings: req.data['settings'])
                    end
                    req.std_api_reply :update, { settings: config.settings }, success: true
                end
            end

            def clear_cache!(msg)
                Lanes.logger.debug "SystemSettings cache reset"
                Lanes::SystemSettings.instance_variable_set(:@config, nil)
            end

            def on_change(call_now: false)
                Thread.new do
                    Lanes.redis_connection(cache: false).subscribe(
                        'lanes-system-configuration-update') do |on|
                        on.message do |channel, msg|
                            ActiveRecord::Base.connection_pool.with_connection do
                                yield SystemSettings.find(msg)
                            end
                        end
                    end
                    if call_now
                        yield SystemSettings.config
                    end
                end
            end

        end

        SystemSettings.on_change do |msg|
            Lanes::SystemSettings.clear_cache!
        end

    end



end
