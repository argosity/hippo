require 'faker'

FactoryGirl.define do
    factory :tenant, class: Hippo::Tenant do
        slug         { Faker::Internet.domain_word }
        name         { Faker::Company.name }
        email        { Faker::Internet.email }
        address      {
            "#{Faker::Address.street_address} #{Faker::Address.city} #{Faker::Address.state}"
        }
        phone_number { Faker::PhoneNumber.phone_number }
     end
end
