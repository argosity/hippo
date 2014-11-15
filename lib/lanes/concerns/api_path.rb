module Lanes::Concerns

    # @see ClassMethods
    module ApiPath
        extend ActiveSupport::Concern

        module ClassMethods

            def api_path
                self.to_s.demodulize.pluralize.underscore.dasherize
            end

            def from_api_path(path)
                name = path.underscore.camelize.singularize
                name = "Lanes::#{name}" unless name=~/^Lanes/
                name.safe_constantize
            end

        end
    end
end
