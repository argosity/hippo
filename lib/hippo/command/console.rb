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
                require 'factory_girl'
                DB.establish_connection
                ActiveRecord::Base.logger = Logger.new STDOUT
                Configuration.apply
                Hippo::Extensions.load_controlling_config
                FactoryGirl.definition_file_paths = Hippo::Extensions.map do |ext|
                    ext.root_path.join('spec/factories')
                end
                FactoryGirl.find_definitions
                MultiTenant.current_tenant = Hippo::Tenant.system
                ext.on_dev_console
                ARGV.clear
                IRB.start
            end

        end
    end
end
