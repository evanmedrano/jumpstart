def setup_oauth_support
  start_with_fresh_oauth_support_file
  add_oauth_support_code
end

def start_with_fresh_oauth_support_file
  run "mkdir spec/support"
  run "touch spec/support/oauth_support.rb"
end

def add_oauth_support_code
  inject_into_file "spec/support/oauth_support.rb" do
    <<-RUBY
module OauthSupport
  def stub_oauth(options = {})
    OmniAuth.config.test_mode = true

    OmniAuth.config.mock_auth[provider.to_sym] =
      OmniAuth::AuthHash.new({
        :provider => "facebook",
        :uid => "12345",
        :info => {
          :email => "facebook_email@example.com",
          :image => "oauth_image.png",
          :name => "Oauth User"
        }
      }.merge(options))
  end
end

RSpec.configure do |config|
  config.include OauthSupport, type: :feature
  config.include OauthSupport, type: :request
end
    RUBY
  end
end
