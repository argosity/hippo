FactoryBot.define do
    factory :<%= file_name %>, class: <%= namespace %>::<%= class_name %> do
        tenant { Hippo::Tenant.current }

    end
end
