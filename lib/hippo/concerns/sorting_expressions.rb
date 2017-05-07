module Hippo::Concerns

    # @see ClassMethods
    module SortingExpressions
        extend ActiveSupport::Concern

        module ClassMethods
            # Add a proc that will be called to add a sort expression to a query.
            # The proc should accept an arel query object and a single direction parameter,
            # which will be a symbol value of :asc or :desc
            # It must return a arel query with the sort applied
            # @param name [String] The name of the expression
            def export_sort( name, &block )
                @sorting_expressions ||= {}
                @sorting_expressions[name.to_s] = block
            end

            def has_sorting_expression?(name)
                @sorting_expressions && @sorting_expressions[name]
            end

            def append_sort_to_query(query, field, dir)
                dir = :asc unless dir == :desc
                if @sorting_expressions && (block = @sorting_expressions[field])
                    block.call(query, dir)
                else
                    query.order(field.gsub(/[^\w|^\.]/,'') + ' ' +
                                  ( ( :asc == dir ) ? 'ASC' : 'DESC' ) )
                end
            end

        end
    end
end
