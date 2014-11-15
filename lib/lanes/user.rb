module Lanes

    class User < Lanes::Model
        has_secure_password

        validates :login, :name, :email, presence: true
        validates :email, email: true, uniqueness: { case_sensitive: false }
        validates :password, length: { minimum: 6 }, allow_nil: true

        whitelist_attributes :password

        def roles
            @cached_roles ||= Access::RoleCollection.new(self)
        end

        def workspace_data
            my_data = attributes.slice('id','login','name','email','created_at',
              'created_by','updated_at','updated_by','role_names')
            { user: my_data, access: Access.for_user(self) }
        end

        # @param model [Lanes::Model]
        # @param attribute [Symbol]
        # @return [Boolean] Can the User view the model?
        def can_read?(model, attribute = nil)
            roles.can_read?(model, attribute)
        end

        # @param model [Lanes::Model]
        # @param attribute [Symbol]
        # @return [Boolean] Can the User create and update the model?
        def can_write?(model, attribute = nil)
            roles.can_write?(model, attribute)
        end

        # @param model [Lanes::Model]
        # @param id [Numberic] the id for the model
        # @return [Boolean] Can the User delete the model?
        def can_delete?(model, id)
            roles.can_delete?(model, id)
        end

        # We override the default implementation so that we can gaurantee
        # that the current user can always update their own information
        USER_EDITABLE_ATTRIBUTES=[:name, :email, :password]
        def setting_attribute_is_allowed?(name, user)
            ( !new_record? && user.id == self.id && USER_EDITABLE_ATTRIBUTES.include?(name) ) ? true : super
        end
        def can_write_attributes?( attr, user )
            ( !new_record? && user.id == self.id ) ? true : super
        end
        def self.can_write_attributes?( attr, user )
            ( attr[:id] && attr[:id].to_i == user.id ) ? true : super
        end



        # If all that's needed is the user's id, see `current_id`,
        # that method does not not attempt to instantiate a User
        # Defaults to nil
        # @return [User] The user who's currently interacting with Lanes.
        def self.current
            uid = Thread.current[:lanes_current_user]
            if uid.is_a?(User)
                uid
            else
                user = Thread.current[:lanes_current_user] = User.find_by_id(uid)
                return user ? user.id : nil
            end
        end

        # Retrieve the current id of the user we're proxying for.
        # get's a bit complicated since we can proxy both for a user object
        # or just the user's id
        # @return [Fixnum] current user's ID.  If the current user is not set, returns 0
        def self.current_id
            uid = Thread.current[:lanes_current_user]
            if uid.nil?
                0
            elsif uid.is_a?(User)
                uid.id
            else
                uid
            end
        end

        # sets the user for the duration of the block
        # @example Inside a Rails controller
        #
        #     class DocumentsController < ApplicationController
        #         around_filter :set_lanes_user
        #
        #         # update's the Document's owner to current
        #         # But sets all the notes to be owned by admin
        #         def update_owner
        #             doc = Document.find(params[:id])
        #             doc.current_owner = Lanes::User.current
        #             Lanes::User.scoped_to( admin_user ) do
        #                 doc.notes.each{ |note| note.set_owner_to_current! } # will set to Lanese::User.current
        #             end
        #         end
        #
        #         private
        #
        #         def set_lanes_user
        #             Lanes::User.scoped_to( session[:user_id] ) do
        #                  yield
        #             end
        #          end
        #      end
        #
        # @return [UserProxy] self
        def self.scoped_to( user )
            prev_user, Thread.current[:lanes_current_user] = self.current, user
            yield user
        ensure
            Thread.current[:lanes_current_user] = prev_user
        end

    end

    require_relative "concerns/track_modifications"

    # We can only use the TrackModifications concern after the User model is defined
    Model.send(:include, Concerns::TrackModifications )

end
