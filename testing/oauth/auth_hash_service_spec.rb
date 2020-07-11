def setup_auth_hash_service_spec
  start_with_fresh_auth_hash_service_spec_file
  add_auth_hash_service_spec_code
end

def start_with_fresh_auth_hash_service_spec_file
  run "mkdir spec/services"
  run "touch spec/services/auth_hash_service_spec.rb"
end

def add_auth_hash_service_spec_code
  inject_into_file "spec/services/auth_hash_service_spec.rb" do
    <<-RUBY
require 'rails_helper'

describe AuthHashService do
  describe "#find_or_create_user_from_auth_hash" do
    it "creates a new user when there is no matching user" do
      user = AuthHashService.new(auth_hash).find_or_create_user_from_auth_hash

      expect(user).to be_persisted
      expect(user.auth_provider).to eq "facebook"
      expect(user.auth_uid).to eq "1"
      expect(user.email).to eq "oauth_user@example.com"
      expect(user.image_url).to eq "test_image.png"
      expect(user.name).to eq "Oauth User"
      expect(user).not_to be_admin
    end

    context "with an existing user" do
      it "finds the user by email" do
        existing_user = create(:user, email: auth_hash["info"]["email"])

        expect(existing_user).to eq AuthHashService.new(auth_hash).
          find_or_create_user_from_auth_hash
      end

      it "finds the user by auth_provider and auth_uid" do
        existing_user = create(:user, auth_provider: "facebook", auth_uid: "1")

        expect(existing_user).to eq AuthHashService.new(auth_hash).
          find_or_create_user_from_auth_hash
      end

      it "updates a user's auth_provider and auth_uid if found via email" do
        existing_user = create(:user, :with_omniauth, provider: "google")
        options = { "info" => { "email" => existing_user.email,
                                "image" => existing_user.image_url,
                                "name" => existing_user.name } }

        expect(existing_user).to eq AuthHashService.new(auth_hash(options)).
          find_or_create_user_from_auth_hash
        expect(existing_user.reload.auth_provider).to eq auth_hash["provider"]
        expect(existing_user.reload.auth_uid).to eq auth_hash["uid"]
      end
    end
  end


  def auth_hash(options = {})
    {
      "provider" => "facebook",
      "uid" => "1",
      "info" => {
        "email" => "oauth_user@example.com",
        "image" => "test_image.png",
        "name" => "Oauth User",
      }
    }.merge(options)
  end
end
    RUBY
  end
end
