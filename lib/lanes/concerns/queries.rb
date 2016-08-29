module Lanes
    module Concerns

        # A collection of handly utility methods to generate queries
        module Queries

            extend ActiveSupport::Concern

            module ClassMethods

                def compose_query_using_detail_view( view: nil, join_to: nil )
                    join_to ||= self.name.demodulize.tableize.singularize + '_' + primary_key
                    q = joins("join #{view} as details on details.#{join_to} = #{table_name}.#{primary_key}")
                          .select("details.*")
                    if current_scope.nil? || current_scope.select_values.exclude?("#{table_name}.*")
                        q = q.select("#{table_name}.*")
                    end
                    q
                end

            end
        end
    end
end
