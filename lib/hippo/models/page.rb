module Hippo
    class Page < Model
        belongs_to_tenant
        belongs_to :owner, polymorphic: true
        has_many :images,
                 class_name: 'Hippo::Asset', as: :owner, dependent: :destroy

        validates :owner_id, uniqueness: { scope: :owner_type, message: 'Only one page per model' }
    end
end
