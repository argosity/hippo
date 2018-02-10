require_relative 'concerns/all'
require 'activerecord-multi-tenant'

module Hippo

    class Model < ::ActiveRecord::Base
        self.abstract_class = true

        include Concerns::PubSub
        include Concerns::ApiAttributeAccess
        include Concerns::ExportMethods
        include Concerns::ExportScope
        include Concerns::ExportAssociations
        include Concerns::ExportJoinTables
        include Concerns::AssociationExtensions
        include Concerns::ApiPath
        include Concerns::CodeIdentifier
        include Concerns::SanitizeFields
        include Concerns::Queries
        include Concerns::SortingExpressions
        include Concerns::RandomIdentifer
        include Concerns::HasPage

        def self.belongs_to_tenant
            belongs_to :tenant, class_name: 'Hippo::Tenant'
            multi_tenant :tenant
        end

        # will be overridden if models call belongs_to_tenant
        def self.scoped_by_tenant?
            false
        end
    end

    autoload :Page, "hippo/models/page"
    autoload :Subscription, "hippo/models/subscription"
end
