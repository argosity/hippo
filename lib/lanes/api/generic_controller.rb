module Lanes
    module API


        class GenericController < ControllerBase

            def show
                query   = build_query
                options = build_reply_options
                query   = add_modifiers_to_query(query)
                options[:total_count] = query.dup.unscope(:select).count if should_include_total_count?
                if params[:id]
                    query  = query.first!
                end
                std_api_reply(:retrieve, query, options)
            end

            def create
                record  = model.from_attribute_data(data, user)
                options = build_reply_options.merge(success: record.save)
                std_api_reply(:create, record, options)
            end

            def update
                if params[:id]
                    perform_single_update( build_query.first! )
                elsif data.is_a?(Array)
                    perform_multiple_updates
                end
            end

            def destroy
                if params[:id]
                    perform_single_destroy
                elsif data.is_a?(Array)
                    perform_multiple_destroy
                end
            end

        end
    end
end
