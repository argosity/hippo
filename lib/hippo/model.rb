require_relative 'concerns/all'

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

    end

end
