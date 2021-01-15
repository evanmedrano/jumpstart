require_relative '../../../support/logger'

def add_devise_jwt_testing_template
  log_status 'Adding request specs for devise jwt.'

  add_requests_directory
  add_requests_specs_for_devise_jwt
  add_registrations_request_spec_code
  add_sessions_request_spec_code
end

def add_requests_directory
  run 'mkdir spec/requests'
end

def add_requests_specs_for_devise_jwt
  run 'touch spec/requests/registrations_request_spec.rb'
  run 'touch spec/requests/sessions_request_spec.rb'
end

def add_registrations_request_spec_code
  inject_into_file 'spec/requests/registrations_request_spec.rb' do
    <<-RUBY
require 'rails_helper'

describe 'Registrations' do
  describe '#create' do
    context 'when the user is unauthenticated' do
      it 'returns a 200 response' do
        params = { user: { email: 'user@example.com', password: 'foobar' } }

        post '/signup', params: params

        expect(response).to have_http_status(:ok)
      end

      it 'returns a new user' do
        params = { user: { email: 'user@example.com', password: 'foobar' } }

        expect { post '/signup', params: params }.to change(User, :count).by(1)
      end
    end

    context 'when the user already exists' do
      it 'returns a bad request status' do
        user = create(:user)
        params = { user: { email: user.email, password: user.password } }

        post '/signup', params: params

        expect(response).to have_http_status(:bad_request)
      end

      it 'returns validation errors' do
        user = create(:user)
        params = { user: { email: user.email, password: user.password } }

        post '/signup', params: params

        json = JSON.parse(response.body)
        expect(json['errors'].first['title']).to eq('Bad Request')
      end
    end
  end
end
    RUBY
  end
end

def add_sessions_request_spec_code
  inject_into_file 'spec/requests/sessions_request_spec.rb' do
    <<-RUBY
require 'rails_helper'

describe 'Sessions' do
  describe '#login' do
    context 'when the params are valid' do
      it 'returns a 200 response' do
        user = create(:user)

        post '/login', params: params_for(user)

        expect(response).to have_http_status(:ok)
      end

      it 'returns an Authorization header' do
        user = create(:user)

        post '/login', params: params_for(user)

        expect(response.headers['Authorization']).to be_present
      end

      it 'returns a valid JWT token' do
        user = create(:user)

        post '/login', params: params_for(user)

        decoded_token = decode_token(response.headers['Authorization'])
        expect(decoded_token.first['sub']).to be_present
      end
    end

    context 'when the params are invalid' do
      it 'returns an unauthorized status' do
        post '/login'

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe '#logout' do
    it 'returns 204, no content' do
      delete '/logout'

      expect(response).to have_http_status(:no_content)
    end
  end

  def params_for(user)
    { user: { email: user.email, password: user.password } }
  end

  def decode_token(token)
    JWT.decode(token.split(' ')[1], ENV['DEVISE_JWT_SECRET_KEY'])
  end
end
    RUBY
  end
end
