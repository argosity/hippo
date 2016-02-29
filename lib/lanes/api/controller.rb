module Lanes
    module API

        # The Controller handles querying models
        # using either pre-defined scopes or hash based queries;
        # and also including optional associations with the reply
        #
        # It assigns the following meaning the these parameters.
        #    * f: (fields)   Include the following fields (usually methods) with the reply
        #    * w: (with)     Uses the defined scope to query and/or add extra data to the model
        #    * q: (query)    Query the model using fields and values
        #         it is an array of clauses, which can be either forms
        #         { field: value }, or { field: { op: 'like', value: 'value%' } }
        #    * i: (include)  Include associations along with the model in the reply
        #    * o: (order)    Order by, { field => "ASC|DESC" }
        #    * l: (limit)    Limit the returned rows to the count
        #    * s: (start)    Start the query at the given offset (for paging)
        #    * df: (data format) Should data be returned as 'object' (default) or 'array'
        # The parameters are deliberately shortened so they can be used in
        # query parameters without blowing the URL up to an unacceptable length

        class Controller

            attr_reader :model, :user, :params, :data
            include FormattedReply

            def initialize(model, authentication, params, data={})
                @user   = authentication.current_user
                @model  = model
                @params = params
                @data   = data
            end

            def perform_retrieval
                query   = build_query
                options = build_reply_options
                query   = add_modifiers_to_query(query)
                options[:total_count] = query.dup.unscope(:select).count if should_include_total_count?
                if params[:id]
                    query  = query.first!
                end
                std_api_reply(:retrieve, query, options)
            end

            def perform_creation
                record  = model.from_attribute_data(data, user)
                options = build_reply_options.merge(success: record.save)
                std_api_reply(:create, record, options)
            end

            def perform_update
                if params[:id]
                    perform_single_update( build_query.first! )
                elsif data.is_a?(Array)
                    perform_multiple_updates
                end
            end

            def perform_destroy
                if params[:id]
                    perform_single_destroy
                elsif data.is_a?(Array)
                    perform_multiple_destroy
                end
            end

            protected

            def perform_single_destroy
                record = model.find(params[:id])
                record.destroy
                std_api_reply(:destroy, record, {})
            end

            def perform_multiple_destroy
                records = model.find( data.map{|rec|rec['id']} )
                success = true
                records.each do | record |
                    if user.can_delete?(record, record.id)
                        success = false unless record.destroy
                    end
                end
                options = build_reply_options.merge(success: success)
                std_api_reply(:destroy, records, options)
            end

            def perform_multiple_updates
                records = model.find( data.map{|rec|rec['id']} )
                success = true
                records.each do | record |
                    record_data = data.detect{ |rd| rd['id'] == record.id }
                    if user.can_write?(record, record.id)
                        record.set_attribute_data(record_data, user)
                        success = false unless record.save
                    end
                end
                options = build_reply_options.merge(success: success)
                std_api_reply(:update, records, options)
            end

            def perform_single_update(record)
                record.set_attribute_data(data, user)
                options = build_reply_options.merge(success: record.save)
                std_api_reply(:update, record, options)
            end

            # @return [Array<String>] The fields to include in query.  May represent either an attribute or a method
            def requested_fields
                [*params[:f]]
            end
            def reply_with_array?
                params[:df] == 'array'
            end
            def query_scopes
                [*params[:w]]
            end
            def query_params
                params[:q]
            end
            def include_associations
                [*params[:i]]
            end
            def sort_order
                params[:o]
            end
            def query_limit_size
                limit = max_query_results_size
                params[:l] ? [ params[:l].to_i, limit ].min : limit
            end
            def query_offset
                params[:s]
            end

            # reply options

            # Should the result include the total number of available records
            def should_include_total_count?
                params[:l] && params[:s] && ! params[:id]
            end

            # Extract options that are suitable for use in 'as_json'
            def build_reply_options
                options = {}
                if include_associations.any?
                    options[:include] = include_associations.each_with_object({}) do |association, includes|
                        includes.merge! build_allowed_associations(association, user)
                    end
                end

                if requested_fields.any?
                    options[:methods] = requested_fields.select{|f| model.has_exported_method?(f,user) }
                end
                options[:format] = reply_with_array? ? 'array' : 'object'
                options
            end

            def build_allowed_associations(association, user, model_class=self.model)
                includes = {}
                if association.is_a?(Hash)
                    association.each do |include_name, sub_associations|
                        if model_class.has_exported_association?(include_name, user) &&
                           ( reflection = model_class.reflect_on_association( include_name.to_sym ) )
                            sub_includes = includes[include_name.to_sym] = {}
                            allowed = build_allowed_associations( sub_associations, user, reflection.klass )
                            unless allowed.empty?
                                sub_includes[:include] ||= []
                                sub_includes[:include] << allowed
                            end
                        end
                    end
                elsif association.is_a?(Array)
                    association.each do | sub_association |
                        if model_class.has_exported_association?(sub_association, user)
                            includes.merge! build_allowed_associations( sub_association, user, model_class )
                        end
                    end
                else
                    includes[ association.to_sym ] = {} if  model_class.has_exported_association?(association,user)
                end
                includes
            end

            # query options

            def build_query(query = model.all)
                if params[:id]
                    query = query.where(id: params[:id])
                end
                if params[:nested_attribute]
                    query = query.where(params[:nested_attribute])
                end
                if query_params.present?
                    query = add_params_to_query(query)
                end
                query
            end

            def add_modifiers_to_query(query)
                if query_scopes.present?
                    query = add_scope_to_query(query)
                end
                query = query.limit(query_limit_size)
                query = query.offset(query_offset.to_i) if query_offset.present?
                if include_associations.any?
                    allowed_includes = include_associations.each_with_object([]) do |desired, results|
                        if desired.is_a?(Hash)
                            nested = {}
                            desired.each do | name, sub_associations |
                                nested[name.to_sym] = sub_associations if model.has_exported_association?(name,user)
                            end
                            results.push(nested) unless nested.empty?
                        else
                            results.push(desired.to_sym) if model.has_exported_association?(desired,user)
                        end
                    end
                    query = query.includes(allowed_includes) unless allowed_includes.empty?
                end
                if sort_order.present?
                    sort_order.each do | fld, dir |
                        query = model.append_sort_to_query(
                            query, fld, dir.downcase.to_sym
                        )
                    end
                end
                query
            end


            def max_query_results_size
                250 # should be enough for everybody, amirite?
            end

            def add_scope_to_query(query)
                query_scopes.each do | name, arg |
                    if model.has_exported_scope?(name,user)
                        args = [name]
                        args.push( arg ) unless arg.blank?
                        query = query.send( *args )
                    end
                end
                query
            end

            def add_params_to_query(query)
                query_params.each do | field, value |
                    next unless ( field = convert_field_to_arel(field) )
                    if value.is_a?(Hash) && value.has_key?('value')
                        op = value['op']
                        value = value['value']
                    end
                    query = query.where(
                        field_to_predicate(field, value, op)
                    )
                end
                query
            end

            def convert_field_to_arel(field)
                if field.include?('.')
                    (table_name, field_name) = field.split('.')
                    if model.has_exported_join_table?(table_name, user)
                        Arel::Table.new(table_name)[field_name]
                    else
                        nil
                    end
                elsif model.attribute_method?(field)
                    model.arel_table[field]
                else
                    Arel::Nodes::SqlLiteral.new(
                        model.connection.quote_column_name(field)
                    )
                end
            end

            # complete list: https://github.com/rails/arel/blob/master/lib/arel/predications.rb
            def field_to_predicate( field, value, op = nil )
                case op
                when nil, 'eq' then field.eq(value)
                when 'like' then field.matches( value )
                when 'ne'   then field.not_eq(value)
                when 'lt'   then field.lt(value)
                when ( op=='in' && value=~/.*:.*/ ) then field.in( Range.new( *value.split(':') ) )
                when 'gt'   then field.gt(value)
                else
                    value =~ /%/ ? field.matches( value ) : field.eq( value )
                end
            end

        end
    end
end
