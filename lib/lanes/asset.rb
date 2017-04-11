module Lanes

    class Asset < Lanes::Model

        include Lanes::Concerns::AssetUploader[:file]

        belongs_to :owner, polymorphic: true

        def present?
            super && file.present?
        end
    end

end
