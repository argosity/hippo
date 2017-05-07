module Hippo::Concerns

    # Event subscription and publishing for Models
    # Every model has certain built-in events (:save, :create, :update, :destroy)
    # And may also implement custom events that reflect the models domain
    # @example Send an email when a customer's name is updated
    #   Customer.observe(:update) do |customer|
    #       Mailer.notify_billing(customer).deliver if customer.name_changed?
    #   end
    # @example Update some stats when a Sku's qty is changed
    #   Sku.observe(:qty_changed) do | sku, location, old_qty, new_qty |
    #       Stats.refresh( location )
    #   end
    module PubSub
        extend ActiveSupport::Concern


        module PendingListeners
            # @private
            @@listeners = Hash.new{ |hash, klass|
                hash[klass] = Hash.new{ |kh, event|
                    kh[event]=Array.new
                }
            }
            class << self

                # @api private
                def claim(class_name)
                    if @@listeners.has_key?(class_name)
                        return @@listeners.delete(class_name)
                    else
                        return {}
                    end
                end

                # @api private
                def add(class_name)
                    @@listeners[class_name]
                end
            end
        end


        class InvalidEvent < RuntimeError
        end

        included do | base |

            class_attribute :valid_event_names
            class_attribute :_event_listeners
            base.valid_event_names = [ :save, :create, :update, :destroy ]

            base.after_save    :fire_after_save_pubsub_events
            base.after_create  :fire_after_create_pubsub_events
            base.after_update  :fire_after_update_pubsub_events
            base.after_destroy :fire_after_destroy_pubsub_events
        end

        module ClassMethods
            def inherited(base)
                super
                klass = base.to_s.demodulize
                events = PubSub::PendingListeners.claim( klass )
                events.each{ | name, procs |
                    procs.each{|pr|
                        base.send(:_add_event_listener, name, &pr)
                    }
                }
            end

            def observe( event, &block )
                unless self.valid_event_names.include?(event.to_sym)
                    raise InvalidEvent.new("#{event} is not a valid event for #{self}")
                end
                _add_event_listener( event.to_sym, &block )
            end

            protected

            def has_additional_events( *names )
                self.valid_event_names += names.map{ |name| name.to_sym }
            end

            private

            def _add_event_listener(name, &block)
                self._event_listeners ||= Hash.new{ |hash, key| hash[key]=Array.new }
                listeners = self._event_listeners[name].dup
                listeners << block
                self._event_listeners = self._event_listeners.dup
                self._event_listeners[name] = listeners
            end
        end

        protected

        def fire_after_destroy_pubsub_events
            fire_pubsub_event(:update, self)
        end

        def fire_after_update_pubsub_events
            fire_pubsub_event(:update, self)
        end

        def fire_after_create_pubsub_events
            fire_pubsub_event(:create, self)
        end

        def fire_after_save_pubsub_events
            fire_pubsub_event(:save, self)
        end

        def fire_pubsub_event(name, *arguments)
            return if self.class._event_listeners.nil? ||
                      !self.class._event_listeners.has_key?(name.to_sym)
            self.class._event_listeners[ name.to_sym ].each{ | block |
                block.call(*arguments)
            }
        end

        private

        def _fire_pubsub_event( name, *arguments )
        end
    end

end
