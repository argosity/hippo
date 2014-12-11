require 'sanitize'

module Lanes
    module Concerns

        # @see ClassMethods
        module SanitizeFields
            extend ActiveSupport::Concern

            module ClassMethods
                # Remove invalid HTML from fields before save
                # by using the "sanitize" gem's Sanitize.fragment method.
                #
                # Defaults to removing all HTML, but a valid Sanitize::Config
                # hash can be specified as well.
                def sanitize_fields(*fields)
                    options = fields.extract_options!
                    using = options[:using] || {}
                    before_save do
                        fields.each do |field|
                            value = read_attribute(field)
                            unless value.blank?
                                write_attribute(field, Sanitize.fragment(sanitized,using))
                            end
                        end
                    end
                end

            end
        end
    end
end
