system = Hippo::Tenant.system
system.perform do
    Hippo::User.seed_admin_account
end

testing = Hippo::Tenant.find_or_create_by(slug: 'dev', name: 'dev testing tenant', email: 'test@test.com')

testing.perform do
    Hippo::User.seed_admin_account
end
