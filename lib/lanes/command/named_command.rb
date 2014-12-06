module Lanes
    module Command

        class NamedCommand < Thor::Group
            include Thor::Actions

            argument :name

            attr_reader :namespace, :class_name, :client_dir

            def self.source_root
                Pathname.new(__FILE__).dirname.join("templates")
            end

            def load_extension
                @namespace  = options[:namespace] || Command.load_current_extension.identifier
                raise Thor::Error("Unable to locate Lanes environment") unless @namespace
                @class_name = name.classify
                @client_dir = "client/#{namespace}"
            end

        end
    end
end
