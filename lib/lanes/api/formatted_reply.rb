module Lanes
    module API
        module FormattedReply
            # json methods
            # constructs a Hash with success, messages, and data keys and
            # populates them appropriately

            def std_api_reply(type, data, options)
                json = { success: options[:success].nil? ? true : options[:success] }
                if data.is_a?(ActiveRecord::Base)
                    record_active_record_errors(data, json)
                end
                if options[:total_count]
                    json[:total] = options.delete(:total_count)
                end
                json.merge(
                  message: options[:messsage] || json_status_str(data, type.to_s.capitalize, json[:success]),
                  data:    json[:success] ? records_for_reply(data, type, options) : []
                )
            end

            def record_active_record_errors(model, json = {})
                return if model.errors.none?
                json[:success] = false
                json[:errors] = {}
                model.errors.each{ | attr, message |
                    json[:errors][attr] = message
                }
                json
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
                    type + " succeeded"
                elsif record
                    msg = type + " failed"
                    if record.is_a?(ActiveRecord::Base)
                        msg += ": " + record.errors.full_messages.join("; ")
                    end
                else
                    return "Record not found"
                end
            end

        end
    end
end
