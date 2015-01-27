module Lanes
    module Command

        class NamedCommand < Thor::Group
            include Thor::Actions

            argument :name

            attr_reader :namespace, :class_name, :client_dir, :spec_dir, :identifier

            def self.source_root
                Pathname.new(__FILE__).dirname.join("templates")
            end

            def load_namespace
                @namespace  = options[:namespace] ||
                  Command.load_current_extension(raise_on_fail:true)
                    .identifier.underscore.camelize
                @identifier = @namespace.underscore.dasherize
            end

            def set_variables
                @class_name = name.underscore.classify
                @spec_dir   = "spec/#{identifier}"
                @client_dir = "client/#{identifier}"
            end

        end
    end
end
