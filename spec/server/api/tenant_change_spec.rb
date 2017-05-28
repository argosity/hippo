# coding: utf-8
require_relative '../spec_helper'

describe "Tenant changes", api: true, vcr: VCR_OPTS do

    let(:tenant) { FactoryGirl.create :tenant, slug: 'foo' }

    let!(:user) { FactoryGirl.create :user, tenant: tenant, role_names: ['administrator'] }

    it 'sends email when tenant identifier changes' do
        post '/api/hippo/tenants.json', {
                 'slug' => 'RED'
             }.to_json, {
                 'HTTP_AUTHORIZATION' => user.jwt_token,
                 'HTTP_ACCEPT' => 'application/json',
                 'SERVER_NAME' => "#{tenant.slug}.example.ua",
             }

        expect(tenant.reload.slug).to eq('RED')
        email = Mail::TestMailer.deliveries.last
        expect(email).not_to be_nil
        expect(email.body).to include(tenant.domain)
    end
end
