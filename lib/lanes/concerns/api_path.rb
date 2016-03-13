module Lanes::Concerns

    # @see ClassMethods
    module ApiPath
        extend ActiveSupport::Concern

        module ClassMethods

            def api_path(with_module: false)
                path = with_module ? to_s : to_s.demodulize
                path.pluralize.underscore.dasherize
            end

            def from_api_path(path)
                name = path.underscore.camelize.singularize

                name = "Lanes::#{name}" unless name=~/^Lanes/
                name.safe_constantize
            end

        end
    end
end
