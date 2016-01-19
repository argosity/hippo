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
                Lanes.redis_connection.publish('lanes-system-configuration-update',
                                               {extension_id=>update})
            end

            def update_handler
                lambda do
                    wrap_reply do
                        config = SystemSettings.config
                        config.update_attributes(settings: data['settings'])
                        Lanes.redis_connection.publish('lanes-system-configuration-update',
                                                       config.settings)
                        std_api_reply :update, { settings: config.settings }, success: true
                    end
                end
            end

        end

        Thread.new do
            Lanes.redis_connection(cache:false).subscribe('lanes-system-configuration-update') do |on|
                on.message do |channel, msg|
                    Lanes::SystemSettings.instance_variable_set(:@config, nil)
                    Lanes::Configuration.apply
                end
            end
        end

    end



end
