module Lanes
    module API


        class GenericController < ControllerBase

            def show
                perform_retrieval
            end

            def create
                record  = model.from_attribute_data(data, user)
                options = build_reply_options.merge(success: record.save)
                std_api_reply(:create, record, options)
            end

            def update
                if params[:id]
                    perform_single_update
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
