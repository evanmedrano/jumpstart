def add_omniauth_callbacks_controller_code
  inject_into_file "app/controllers/omniauth_callbacks_controller.rb" do
    <<-RUBY
class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    sign_in user_from_auth_hash
    redirect_to root_url, notice: "Facebook authentication successful."
  end

  def google_oauth2
    sign_in user_from_auth_hash
    redirect_to root_url, notice: "Google authentication successful."
  end

  private

  def user_from_auth_hash
    AuthHashService.new(auth_hash).find_or_create_user_from_auth_hash
  end

  def auth_hash
    request.env["omniauth.auth"]
  end
end
    RUBY
  end
end
