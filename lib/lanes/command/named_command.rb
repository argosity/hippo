module Lanes
    module Command

        class NamedCommand < Thor::Group
            include Thor::Actions

            argument :name

            attr_reader :namespace, :class_name, :client_dir, :spec_dir, :identifier

            def self.source_root
                Pathname.new(__FILE__).dirname.join("..","..","..","templates")
            end

            def load_namespace
                @identifier = extension.identifier
                @namespace  = options[:namespace] || @identifier.underscore.camelize
            end

            def set_variables
                @class_name = name.underscore.camelize
                @spec_dir   = "spec/client"
                @client_dir = "client/#{identifier}"
            end

            protected

            def extension
                @extension ||= Command.load_current_extension(raise_on_fail:true)
            end
        end
    end
end
