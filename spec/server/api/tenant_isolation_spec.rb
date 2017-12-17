# coding: utf-8
require_relative '../spec_helper'

describe "Tenant isoloation", api: true, vcr: VCR_OPTS do

    let(:foo) { FactoryBot.create :tenant, slug: 'foo' }
    let(:bar) { FactoryBot.create :tenant, slug: 'bar' }

    let!(:foo_user) { FactoryBot.create :user, tenant: foo }
    let!(:bar_user) { FactoryBot.create :user, tenant: bar }

    before(:each) {
        Hippo.logger.level = ::Logger::ERROR
    }
    it 'isolates foo’s tenant data from bar' do
        with_payment_proccessor do
            get '/api/hippo/user.json', {} , {
                    'HTTP_AUTHORIZATION' => foo_user.jwt_token,
                    'SERVER_NAME' => "#{foo.slug}.example.ua" }
            ids = last_response_json['data'].map { |u| u['id'] }
            expect(ids).to include(foo_user.id)
            expect(ids).not_to include(bar_user.id)
        end
    end

    it 'isolates bar’s tenant data from foo' do
        with_payment_proccessor do
            get '/api/hippo/user.json', {}, {
                    'HTTP_AUTHORIZATION' => bar_user.jwt_token,
                    'SERVER_NAME' => "#{bar.slug}.example.ua" }
            ids = last_response_json['data'].map { |u| u['id'] }
            expect(ids).to include(bar_user.id)
            expect(ids).not_to include(foo_user.id)
        end
    end

    it 'disallows using a user’s token on incorrect domain' do
        with_payment_proccessor do
            get '/api/hippo/user.json', {}, {
                    'HTTP_AUTHORIZATION' => foo_user.jwt_token,
                    'SERVER_NAME' => "#{bar.slug}.example.ua" }
            expect(last_response).to_not be_ok
            expect(last_response.status).to eq 401
        end
    end
end
