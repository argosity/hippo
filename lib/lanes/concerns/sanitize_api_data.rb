module Lanes::Concerns


    # SanitizeJson is responsible for only cleaning a hash of attributes that should not
    # be written to the model by the given user
    module SanitizeApiData
        extend ActiveSupport::Concern

        module ClassMethods
        end

    end


end
