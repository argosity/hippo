require_relative 'concerns/all'

module Lanes


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
        include Concerns::SanitizeFields

    end

end
