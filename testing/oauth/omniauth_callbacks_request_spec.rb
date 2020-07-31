def setup_omniauth_callbacks_request_spec
  start_with_fresh_omniauth_callbacks_request_spec
  add_omniauth_callbacks_request_spec_code
end

def start_with_fresh_omniauth_callbacks_request_spec
  run "rm spec/requests/omniauth_callbacks_request_spec.rb"
  run "touch spec/requests/omniauth_callbacks_request_spec.rb"
end

def add_omniauth_callbacks_request_spec_code
  inject_into_file "spec/requests/omniauth_callbacks_request_spec.rb" do
    <<-RUBY
require 'rails_helper'

RSpec.describe "OmniauthCallbacks", type: :request do
  describe "#facebook" do
    context "when the user is new" do
      it "creates a new user" do
        stub_oauth

        get "/users/auth/facebook/callback"

        expect(User.count).to eq(1)
      end
    end

    context "when the user exists" do
      it "logs in the user" do
        user = create(:user)

        stub_oauth(info: { email: user.email })

        get "/users/auth/facebook/callback"

        expect(User.count).to eq(1)
        expect(flash.notice).to eq("Facebook authentication successful.")
      end
    end

    context "when the user has another oauth provider set" do
      it "updates the oauth provider facebook and logs the user in" do
        user = create(:user, :with_omniauth, provider: "google")

        stub_oauth(info: { email: user.email })

        get "/users/auth/facebook/callback"

        expect(user.reload.auth_provider).to eq("facebook")
        expect(flash.notice).to eq("Facebook authentication successful.")
      end
    end
  end

  describe "#google" do
    context "when the user is new" do
      it "creates a new user" do
        stub_oauth(provider: :google_oauth2)

        get "/users/auth/google_oauth2/callback"

        expect(User.count).to eq(1)
      end
    end

    context "when the user exists" do
      it "logs in the user" do
        user = create(:user)

        stub_oauth(provider: :google_oauth2, info: { email: user.email })

        get "/users/auth/google_oauth2/callback"

        expect(User.count).to eq(1)
        expect(flash.notice).to eq("Google authentication successful.")
      end
    end

    context "when the user has another oauth provider set" do
      it "updates the oauth provider to google_oauth2 and logs the user in" do
        user = create(:user, :with_omniauth)

        stub_oauth(provider: :google_oauth2, info: { email: user.email })

        get "/users/auth/google_oauth2/callback"

        expect(user.reload.auth_provider).to eq("google_oauth2")
        expect(flash.notice).to eq("Google authentication successful.")
      end
    end
  end
end
    RUBY
  end
end
