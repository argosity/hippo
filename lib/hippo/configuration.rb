require_relative "concerns/attr_accessor_with_default"
require 'securerandom'
require 'pathname'
require 'shrine'
require 'active_job'
require 'jobba'
require 'webpack_driver'
require 'yaml'
require 'hashie/mash'
require 'shrine/storage/file_system'

module Hippo

    class Configuration
        include Concerns::AttrAccessorWithDefault
        attr_reader :secrets

        # Since changing a config value inadvertently
        # can have pretty drastic consequences that might not be
        # discovered immediately, we log each time a value is changed
        def self.config_option( name, default, options={} )
            define_method( "#{name}=" ) do | value |
                old_value = self.send( name )
                if value != old_value && !options[:silent]
                    Hippo.logger.info "Config option #{name} changed from '#{old_value.inspect}' to '#{value.inspect}'"
                end
                instance_variable_set("@#{name}", value)
                if @observers.has_key?(name)
                    @observers[name].each{ |cb| cb.call(value, old_value) }
                end
            end
            attr_reader_with_default(name, default)
        end

        def initialize
            @observers=Hash.new{ |hash,key| hash[key] = Array.new }
            @secrets = Hashie::Mash.new
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

        def apply
            Oj.default_options = { mode: :rails, time_format: :xmlschema }

            controlling_ext = Hippo::Extensions.bootstrap
            secpath = controlling_ext.root_path.join('config', 'secrets.yml')

            @secrets = Hashie::Mash.new(
                secpath.file? ? YAML.load(ERB.new(secpath.read).result) : {}
            )

            ActiveJob::Base.queue_adapter = Hippo.env.test? ? :test : :resque
            Hippo::Job::FailureLogger.configure

            DB.establish_connection

            Jobba.configure do |config|
                config.redis_options = Hippo.config.redis
                config.namespace = "#{controlling_ext.identifier}::jobba"
            end

            Resque.redis.namespace = "#{controlling_ext.identifier}::resque"
            Resque.redis = Hippo.config.redis
            Hippo::Concerns::AssetUploader.storages = {
                cache: Shrine::Storage::FileSystem.new(
                    controlling_ext.root_path,
                    prefix: "tmp/cache"
                ),
                store: Shrine::Storage::FileSystem.new(
                    controlling_ext.root_path,
                    prefix: "public/files"
                )
            }
            Hippo::Tenant.system.perform do
                Hippo::SystemSettings.for_ext('hippo').apply!
                Extensions.each{|ext| ext.apply_configuration }

                if Kernel.const_defined?(:Guard) && ::Guard.const_defined?(:Jest)
                    ::Guard::Jest.logger = Hippo.logger
                end
            end
        end
    end

    class DefaultConfiguration < Configuration

        # Since the Configuration class is essentially a singleton,
        # we don't care about AttrReaderWithDefault sharing values between instances
        # Therefore all the values are given directly and not enclosed in Procs/lambdas.

        # The configuration environment to use, test, development, production
        config_option :environment, (ENV['HIPPO_ENV'] || ENV['RACK_ENV'] || ENV['RAILS_ENV'] || 'development').to_sym

        # The secret key to use for session cookies.
        config_option :session_secret_key_base, ENV['SECRET_KEY'] || '1234', silent: true

        # Configuration for Redis
        config_option :redis, ENV.has_key?('REDIS_URL') ?
           {url: ENV["REDIS_URL"]} : {path: "/tmp/redis.sock"}

        # scheme + host to use for assets
        config_option :asset_host, ENV['ASSET_HOST'] || ENV['HOST'] || ''

        # url prefix to use for assets
        config_option :assets_path_prefix, "/assets"

        # url prefix to use for generated pdf's
        config_option :print_path_prefix, "/print"

        # prefix to use for all urls
        config_option :mounted_at, '/'

        # Configuration for action cable
        config_option :cable, { 'adapter' => 'redis' }

        # types of assets to include into compiled package
        config_option :static_asset_types, ['images','fonts']

        config_option :website_domain, ENV['HOST'] || ''
        config_option :support_email, ''
        config_option :product_name, ''

        def api_path
            mounted_at + 'api'
        end

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
