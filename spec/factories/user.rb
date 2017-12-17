FactoryBot.define do
    factory :user, class: Hippo::User do
        name { Faker::Name.name }
        email { Faker::Internet.email }
        login { Faker::Internet.user_name }

        password 'password'
        password_confirmation 'password'
        role_names ['administrator']
    end
end
