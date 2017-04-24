FactoryGirl.define do
    factory :user, class: Lanes::User do
        name { Faker::Name.name }
        email { Faker::Internet.email }
        login { Faker::Internet.user_name }

        password 'password'
        password_confirmation 'password'
        role_names ['administrator']
    end
end
