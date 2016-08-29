module Lanes::Concerns

    # Extends Rails updated_by and created_by timestamps to also track who created and updated the model.
    # It reads the current user's id from User.current_id when saving and updating the record
    # The class_name for the created_by and updated_by is set to {Lanes::Configuration#user_model}
    module TrackModifications
        extend ActiveSupport::Concern

        included do
            class_attribute :record_modifications, :instance_writer=>false
            self.record_modifications = true

            belongs_to :created_by, :class_name=>Lanes::User
            belongs_to :updated_by, :class_name=>Lanes::User

            self.blacklist_attributes :created_at, :updated_at, :created_by_id, :updated_by_id
            before_update :record_update_modifications
            before_create :record_create_modifications

            self.export_scope :with_user_logins
        end

        module ClassMethods

            def with_user_logins
                q = self; t = table_name
                if current_scope.nil? || current_scope.select_values.exclude?("#{t}.*")
                    q = q.select("#{t}.*")
                end
                if self.column_names.include?('created_by_id')
                    q = q.select("created_by_user.login as created_by_login")
                          .joins("left join lanes_users as created_by_user on " \
                                 "created_by_user.id = #{t}.created_by_id")
                end
                if self.column_names.include?('updated_by_id')
                    q = q.select("updated_by_user.login as updated_by_login")
                          .joins("left join lanes_users as updated_by_user on " \
                                 "updated_by_user.id = #{t}.updated_by_id")
                end
                q
            end

        end

        private

        def _record_user_to_column( column )
            user_id = Lanes::User.current_id ? Lanes::User.current_id : 0
            write_attribute( column, user_id ) if self.class.column_names.include?( column )
        end

        def record_create_modifications
            if self.record_modifications
                _record_user_to_column('updated_by_id')
                _record_user_to_column('created_by_id')
            end
            true
        end

        def record_update_modifications
            if self.record_modifications && should_record_timestamps?
                _record_user_to_column('updated_by_id')
            end
            true
        end

        def change_tracking_fields
            %w{updated_by_id created_by_id updated_at created_at}
        end
    end

end
