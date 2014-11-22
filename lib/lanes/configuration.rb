require_relative "concerns/attr_accessor_with_default"
require 'securerandom'
require 'pathname'
module Lanes

    class Configuration
        include Concerns::AttrAccessorWithDefault

        # Since changing a config value inadvertently
        # can have pretty drastic consequences that might not be
        # discovered immediately, we log each time a value is changed
        def self.config_option( name, default, options={} )
            define_method( "#{name}=" ) do | value |
                old_value = self.send( name )
                if old_value && Lanes.logger && !options[:silent]
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

    end

    class DefaultConfiguration < Configuration

        # Since the Configuration class is essentially a singleton,
        # we don't care about AttrReaderWithDefault sharing values between instances
        # Therefore all the values are given directly and not enclosed in Procs/lambdas.

        # Database tables will have this prefix applied to them
        config_option :table_prefix, ''

        config_option :debug_assets, false
        config_option :default_javascript_tag_options, {}

        config_option :environment, (ENV['RACK_ENV'] || 'development').to_sym
        # The secret key to use for session cookies.
        config_option :session_secret_key_base,  '1234', silent: true
        config_option :redis, { path: "/tmp/redis.sock" }
        config_option :pubsub_key, nil
        config_option :pubsub_host, nil
        config_option :pubsub_timeout, 10

        config_option :es6_transpiler_path, '6to5'
        config_option :es6_transpiler_options, '-t '
        config_option :app_title, "Lanes Test"
        config_option :assets_path_prefix, "/assets"
        config_option :mounted_at, ''

        config_option :specs_root, Pathname.getwd
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
