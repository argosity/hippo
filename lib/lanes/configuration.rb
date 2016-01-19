require_relative "concerns/attr_accessor_with_default"
require 'securerandom'
require 'pathname'
require 'carrierwave'
require 'fog'

module Lanes

    class Configuration
        include Concerns::AttrAccessorWithDefault

        # Since changing a config value inadvertently
        # can have pretty drastic consequences that might not be
        # discovered immediately, we log each time a value is changed
        def self.config_option( name, default, options={} )
            define_method( "#{name}=" ) do | value |
                old_value = self.send( name )
                if old_value && !options[:silent]
                    Lanes.logger.info "Config option #{name} changed from '#{old_value.inspect}' to '#{value.inspect}'"
                end
                instance_variable_set( "@#{name}", value )
                if @observers.has_key?(name)
                    @observers[name].each{ |cb| cb.call(value, old_value) }
                end
            end
            attr_reader_with_default(name, default)
        end

        def initialize
            @observers=Hash.new{ |hash,key| hash[key] = Array.new }
        end

        def on_change(config, &block)
            @observers[config.to_sym] << block
        end

        def get(config, &block)
            value = self.send(config.to_sym)
            if block
                on_change(config,&block)
                block.call( value, value )
            end
            value
        end

        def self.apply
            CarrierWave.configure do |config|
                settings = Lanes::SystemSettings.for_ext('lanes')
                config.storage = settings.file_storage ? settings.file_storage.to_sym : :file
                config.root = settings.storage_dir || Lanes::Extensions.controlling.root_path.join('public')
                config.asset_host = Lanes.config.mounted_at + '/file'
                config.fog_credentials = settings.fog_credentials
                config.ignore_integrity_errors = false
                config.ignore_processing_errors = false
                config.ignore_download_errors = false
            end
            Extensions.each{|ext| ext.apply_configuration }
        end

    end

    class DefaultConfiguration < Configuration

        # Since the Configuration class is essentially a singleton,
        # we don't care about AttrReaderWithDefault sharing values between instances
        # Therefore all the values are given directly and not enclosed in Procs/lambdas.

        # The configuration environment to use, test, development, production
        config_option :environment, (ENV['LANES_ENV'] || ENV['RACK_ENV'] || ENV['RAILS_ENV'] || 'development').to_sym

        # The secret key to use for session cookies.
        config_option :session_secret_key_base,  '1234', silent: true

        # Configuration for Redis
        config_option :redis, ENV.has_key?('REDISTOGO_URL') ?
           {url: ENV["REDISTOGO_URL"]} : {path: "/tmp/redis.sock"}

        # url prefix to use for assets
        config_option :assets_path_prefix, "/assets"

        # prefix to use for all urls
        config_option :mounted_at, '/api'

        # The initial view class to display
        config_option :root_view, 'Lanes.Workspace.Layout'

        # Screen to display on load (if workspace extension is used)
        config_option :initial_workspace_screen_id, ''

        # types of assets to include into compiled package
        config_option :static_asset_types, ['images','fonts']

        config_option :configuration_id, (ENV['LANES_CONFIG_ID'] || 1)
    end

    class << self
        @@config = DefaultConfiguration.new
        def config
            @@config
        end

        def configure
            yield(@@config)
        end
    end

end
