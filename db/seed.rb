Lanes::DB::Seed.add do

    # This could totes be better written

    unless Lanes::User.exists?(1)
        u = Lanes::User.new( name: "Administrator Tester", email: "admin-test@stockor.org",
          login: "admin", role_names: ['administrator'] )
        u.id = 1
        u.password = "password"
        u.save!
    end

    unless Lanes::User.exists?(2)
        u = Lanes::User.new( name: "Accounting Tester", email: "accounting-test@stockor.org",
          login: "accounting", role_names: ['accounting'] )
        u.id = 2
        u.password = "password"
        u.save!
    end

    unless Lanes::User.exists?(3)
        u = Lanes::User.new( name: "Customer Support Tester", email: "support-test@stockor.org",
          login: "support", role_names: ['customer_support'] )
        u.id = 3
        u.password = "password"
        u.save!
    end

    unless Lanes::User.exists?(4)
        u = Lanes::User.new( name: "Purchasing Tester", email: "purchasing-test@stockor.org",
          login: "purchasing", role_names: ['purchasing'] )
        u.id = 4
        u.password = "password"
        u.save!
    end

end
