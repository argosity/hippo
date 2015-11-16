module Lanes
    module API
        module FormattedReply
            # json methods
            # constructs a Hash with success, messages, and data keys and
            # populates them appropriately

            def std_api_reply(type, data, options)
                success = options[:success].nil? ? true : options[:success]
                json = {}
                if data.is_a?(ActiveRecord::Base) && data.errors.any?
                    json[:errors] = {}
                    success = false
                    data.errors.each{ | attr, message |
                        json[:errors][attr] = message
                    }
                end
                if options[:total_count]
                    json[:total] = options.delete(:total_count)
                end
                json.merge(
                  success: success,
                  message: options[:messsage] || json_status_str(data, type.to_s.capitalize, success),
                  data:    success ? records_for_reply(data, type, options) : []
                )
            end

            # @return Array<Array> returns either an array of fields
            def records_for_reply(data, type, options)
                return [] if :destroy == type
                if options[:format] == 'array'
                    data.pluck( *requested_fields )
                else
                    data.as_json(options)
                end
            end

            def json_status_str(record, type, success)
                if success
                    return type + " succeeded"
                elsif record
                    return type + " failed: " + record.errors.full_messages.join("; ")
                else
                    return "Record not found"
                end
            end

        end
    end
end
