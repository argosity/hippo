module Lanes::Concerns

    module ApiAttributeAccess


        extend ActiveSupport::Concern

        included do
            class_attribute :blacklisted_attributes
            class_attribute :whitelisted_attributes
            include AccessChecks
        end

        module AccessChecks
            # Can the API read data from the model?
            def can_read_attributes?(params, user)
                return user.can_read?(self, params)
            end

            # Can the API write data to the model?
            # This check is performed before we bother checking each attribute individually
            def can_write_attributes?(params, user)
                return user.can_write?(self, params)
            end

            # Can the API delete the model?
            # This check is performed before we bother checking each attribute individually
            def can_delete_attributes?(params, user)
                return user.can_delete?(self, params)
            end
        end

        module ClassMethods

            # @param attributes [Array of symbols] attributes that are safe for the API to set
            def whitelist_attributes( *attributes )
                options = attributes.extract_options!
                self.whitelisted_attributes ||= {}
                attributes.each{|attr| self.whitelisted_attributes[ attr.to_sym ] = options }
            end

            # @param attributes [Array of symbols] attributes that are not safe for the API to set
            def blacklist_attributes( *attributes )
                options = attributes.extract_options!
                self.blacklisted_attributes ||= {}
                attributes.each{|attr| self.blacklisted_attributes[ attr.to_sym ] = options }
            end

            def from_attribute_data(data,user)
                record = self.new
                record.set_attribute_data(data, user)
                record
            end

            include AccessChecks
        end


        # An attribute is allowed if it's white listed
        # or it's a valid attribute and not black listed
        # @param name [Symbol]
        # @param user [User] who is performing request
        def setting_attribute_is_allowed?(name, user)
            return false unless user.can_write?(self, name)
            (self.whitelisted_attributes && self.whitelisted_attributes.has_key?( name.to_sym)) ||
            (
              self.attribute_names.include?( name.to_s ) &&
              ( self.blacklisted_attributes.nil? ||
                ! self.blacklisted_attributes.has_key?( name.to_sym )  )
            )
        end

        # Takes in a hash containing attribute name/value pairs, as well as sub hashes/arrays.
        # Sets all the attributes that are allowed and recursively sets sub-associations as well
        # @param data [Hash]
        # @param user [User] who is performing request
        # @returns
        def set_attribute_data(data, user)

            return {} unless self.can_write_attributes?(data, user)

            data.each_with_object(Hash.new) do | (key, value), result |
                # First we set all the attributes that are allowed
                if self.setting_attribute_is_allowed?(key.to_sym, user)
                    result[key] = value
                    public_send("#{key}=", value)
                elsif value.present?
                    # allow nested params to be specified using Rails _attributes
                    name = key.to_s.gsub(/_attributes$/,'').to_sym

                    next unless self.class.has_exported_nested_attribute?(name, user)

                    association = self.association(name)
                    if value.is_a?(Hash) && [:belongs_to,:has_one].include?(association.reflection.macro)
                        target = send(name) || association.build
                        result[name] = target.set_attribute_data(value, user)
                    elsif value.is_a?(Array) && :has_many == association.reflection.macro
                        result[name] = _set_attribute_data_from_collection(association, value, user)
                    end
                end
            end
        end

        def _set_attribute_data_from_collection(association, value, user)

            records = if association.loaded?
                                   association.target
                               else
                                   attribute_ids = value.map {|a| a['id'] || a[:id] }.compact
                                   attribute_ids.empty? ? [] : association.scope.where(
                                     association.klass.primary_key => attribute_ids
                                   )
                               end

            value.map do | association_data |
                record = if association_data['id'].blank?
                             association.build
                         else
                             records.detect{ |r| r.id.to_s == value['id'].to_s }
                         end
                record.set_attribute_data(association_data, user) if record
            end
        end

    end

end
