# coding: utf-8
require_relative '../spec_helper'

describe "Tenant changes", api: true, vcr: VCR_OPTS do

    let(:tenant) { FactoryBot.create :tenant, slug: 'foo' }

    let!(:user) { FactoryBot.create :user, tenant: tenant, role_names: ['administrator'] }

    around(:each){ |spec| with_payment_proccessor { spec.run } }

    it 'sends email when tenant identifier changes' do
        put "/api/hippo/tenant/#{tenant.identifier}.json", {
                'slug' => 'RED'
            }.to_json, {
                'HTTP_AUTHORIZATION' => user.jwt_token,
                'HTTP_ACCEPT' => 'application/json',
                'CONTENT_TYPE' => 'application/json',
                'SERVER_NAME' => "#{tenant.slug}.example.ua",
            }
        expect(tenant.reload.slug).to eq('red')
        email = Mail::TestMailer.deliveries.last
        expect(email).not_to be_nil
        expect(email.body).to include(tenant.domain)
    end
end
