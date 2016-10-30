module Lanes

    class SystemSettings < Lanes::Model

        has_one :logo, as: :owner, :class_name=>'Lanes::Asset', :dependent => :destroy

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

        class << self
            def config
                @config ||= SystemSettings.find_or_create_by(id: Lanes.config.configuration_id)
            end

            def for_ext(extension_id)
                ExtensionSettings.new(extension_id, config.settings[extension_id])
            end

            def persist!(extension_id, update)
                config.settings[extension_id] = update
                config.settings_will_change!
                config.save!
            end

            def update_handler
                lambda do
                    wrap_reply do
                        config = SystemSettings.config
                        if data['settings'].is_a?(Hash)
                            config.update_attributes!(settings: data['settings'])
                        end
                        std_api_reply :update, { settings: config.settings }, success: true
                    end
                end
            end

            def clear_cache!(msg)
                Lanes.logger.debug "SystemSettings cache reset"
                Lanes::SystemSettings.instance_variable_set(:@config, nil)
            end
        end

        Thread.new do
            Lanes.redis_connection(cache:false).subscribe(
                'lanes-system-configuration-update') do |on|
                on.message do |channel, msg|
                    ActiveRecord::Base.connection_pool.with_connection do
                        Lanes::SystemSettings.clear_cache!(msg)
                    end
                end
            end
        end

    end



end
