FactoryBot.define do
    factory :subscription, class: Hippo::Subscription do
        tenant { Hippo::Tenant.current }

    end
end
