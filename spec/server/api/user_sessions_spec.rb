require_relative '../spec_helper'

describe "User Login", api: true, vcr: VCR_OPTS do

    let!(:user) { FactoryGirl.create :user, login: 'SamTheMan', password: 'password' }

    it 'logs in using case insensitive logins' do
        post '/api/hippo/user-session.json', {
                 'login' => 'samTheman',
                 'password' => 'password'
             }.to_json
        expect(last_response_json['success']).to eq(true)
        expect(last_response_json.dig('data', 'user', 'login')).to eq(user.login)
    end
end
