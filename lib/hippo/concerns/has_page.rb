module Hippo
    module Concerns

        module HasPage

            module IncludedMetods
                def with_page_details_view
                    view = 'page_details'
                    q = select("#{view}.page").joins(
                        "left join #{view} on owner_id = #{table_name}.id and owner_type='#{name}'"
                    )
                    if current_scope.nil? || current_scope.select_values.exclude?("#{table_name}.*")
                        q = q.select("#{table_name}.*")
                    end
                    q
                end
            end

            extend ActiveSupport::Concern

            module ClassMethods

                def has_page
                    has_one :page,
                            class_name: 'Hippo::Page',
                            as: :owner,
                            dependent: :destroy,
                            export: true
                    extend IncludedMetods
                end

            end
        end
    end
end
