module Lanes

    class Asset < Lanes::Model

        include Lanes::Concerns::AssetUploader[:file]

        belongs_to :owner, polymorphic: true

        validates :owner,  set: true

    end

end
