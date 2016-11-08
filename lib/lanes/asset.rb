module Lanes

    class Asset < Lanes::Model

        include Lanes::Concerns::AssetUploader[:file]

        belongs_to :owner, polymorphic: true

        validates :owner_id, :owner_type, presence: true

        def present?
            super && file.present?
        end
    end

end
