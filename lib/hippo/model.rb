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

        def self.belongs_to_tenant
            belongs_to :tenant, class_name: 'Hippo::Tenant'
            multi_tenant :tenant
        end

    end

end
