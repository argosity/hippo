require_relative '../spec_helper'

describe "User Create/Update", api: true, vcr: VCR_OPTS do

    let(:user) {
        FactoryGirl.create :user, login: 'SamTheMan', password: 'password', role_names: ['employee']
    }

    let(:new_user_data) {
        { 'login' => 'bob', 'name' => 'Bob',
          'email' => 'bob@test.com', 'password' => 'new-password' }
    }

    it 'can create user when admin' do
        user.update_attributes(role_names: ['administrator'])
        post '/api/hippo/user.json', new_user_data.to_json, { 'HTTP_AUTHORIZATION' => user.jwt_token }
        expect(last_response_json['success']).to eq(true)
        expect(last_response_json.dig('data', 'login')).to eq('bob')
    end

    it 'fails when user is not admin' do
        Hippo.silence_logs do
            post '/api/hippo/user.json', new_user_data.to_json, { 'HTTP_AUTHORIZATION' => user.jwt_token }
        end
        expect(last_response_json['success']).to eq(false)
        expect(last_response_json['message']).to eq('Access Denied')
    end

    it 'allows user to update own account' do
        put("/api/hippo/user/#{user.id}.json",
            new_user_data.merge('id' => user.id).to_json,
            {'HTTP_AUTHORIZATION' => user.jwt_token})
        expect(last_response_json['success']).to eq(true)
        expect(user.reload.login).to eq('SamTheMan')
        expect(user.authenticate('new-password')).not_to eq(false)
    end

end
