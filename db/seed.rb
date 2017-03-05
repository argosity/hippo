module Lanes

    module DBSeed

        user = Lanes::User.where(login: 'admin').first
        if user.nil?
            user = Lanes::User.create!(name: "Admin", email: "admin@test.com",
                                       password: 'password', password_confirmation: 'password',
                                       login: 'admin', role_names: ['administrator'])

        end
    end

end
