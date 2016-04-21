module Lanes

    class SystemSettings < Lanes::Model

        mount_uploader :logo, Lanes::Concerns::ImageUploader

        class ExtensionSettings < OpenStruct
            def initialize(ext_id, settings)
                @extension_id = ext_id
                super(settings)
            end
            def persist!
                SystemSettings.persist!(@extension_id, self.to_h)
            end
            def apply!
                CarrierWave.configure do |config|
                    config.storage = Lanes.config.storage_type.to_sym
                    config.root = Lanes::Extensions.controlling
                                    .root_path.join('public/files').to_s
                    config.asset_host = Lanes.config.api_path + '/file'
                    config.fog_credentials = self.fog_credentials
                    config.ignore_integrity_errors = false
                    config.ignore_processing_errors = false
                    config.ignore_download_errors = false
                end
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
                Lanes::Configuration.apply
            end
        end

        Thread.new do
            Lanes.redis_connection(cache:false).subscribe(
                'lanes-system-configuration-update') do |on|
                on.message do |channel, msg|
                    Lanes::SystemSettings.clear_cache!(msg)
                end
            end
        end

    end



end
