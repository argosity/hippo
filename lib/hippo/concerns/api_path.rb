module Hippo::Concerns

    # @see ClassMethods
    module ApiPath
        extend ActiveSupport::Concern

        module ClassMethods

            def api_path(with_module: false)
                path = with_module ? to_s : to_s.demodulize
                path.underscore.dasherize
            end

            def from_api_path(path)
                name = path.underscore.camelize.safe_constantize
            end

        end
    end
end
