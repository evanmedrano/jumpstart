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
  def stub_oauth(user = nil, provider)
    OmniAuth.config.test_mode = true

    OmniAuth.config.mock_auth[provider.to_sym] =
      OmniAuth::AuthHash.new({
        :provider => "\#{provider}",
        :uid => "12345",
        :info => {
          :email => user_email(user),
          :image => "oauth_image.png",
          :name => "Oauth User"
        }
      })
  end

  def user_email(user)
    if user.nil?
      return "oauth_user@example.com"
    end

    user.email
  end
end

RSpec.configure do |config|
  config.include OauthSupport, type: :feature
  config.include OauthSupport, type: :request
end
    RUBY
  end
end
