require_relative 'concerns/all'

module Lanes


    class Model < ::ActiveRecord::Base
        self.abstract_class = true

        include Concerns::PubSub
        include Concerns::ApiAttributeAccess
        include Concerns::LockedFields
        include Concerns::CodeIdentifier
        include Concerns::RandomHashCode
        include Concerns::VisibleIdIdentifier
        include Concerns::ImmutableModel
        include Concerns::ExportMethods
        include Concerns::ExportScope
        include Concerns::ExportAssociations
        include Concerns::ExportJoinTables
        include Concerns::SanitizeApiData
        include Concerns::AssociationExtensions
        include Concerns::ApiPath

    end

end
