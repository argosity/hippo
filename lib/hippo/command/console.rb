require_relative '../api/updates'

module Hippo
    module Command

        class Console < Thor::Group
            include Thor::Actions

            def start
                ext = Command.load_current_extension
                require 'irb'
                require 'irb/completion'
                require 'pp'
                require 'faker'
                require 'factory_bot'
                DB.establish_connection
                ActiveRecord::Base.logger = Logger.new STDOUT
                Hippo.config.apply
                Hippo::Extensions.load_controlling_config
                FactoryBot.definition_file_paths = Hippo::Extensions.map do |ext|
                    ext.root_path.join('spec/factories')
                end
                FactoryBot.find_definitions
                Hippo::API::Cable.configure
                MultiTenant.current_tenant = Hippo::Tenant.find_by_slug(
                    Hippo.env.development? ? 'dev' : 'system'
                )
                ext.on_dev_console
                Pry::Commands.block_command "tenant", "set current tenant to <slug>" do |slug|
                    MultiTenant.current_tenant=Hippo::Tenant.find_by_slug!(slug)
                    puts "Current tenant id = #{MultiTenant.current_tenant.id}"
                end
                Pry.start
            end

        end
    end
end
