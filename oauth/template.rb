require_relative "../support/rails_helpers"
require_relative "../testing/oauth/auth_hash_service_spec"
require_relative "../testing/oauth/omniauth_callbacks_request_spec"
require_relative "../testing/oauth/oauth_support"
require_relative "../testing/oauth/user_factory"
require_relative "auth_hash_service"
require_relative "omniauth_callbacks_controller"

def add_oauth
  setup_oauth_gems
  setup_oauth_for_devise
  setup_oauth_controller
  setup_auth_hash_service
  setup_oauth_tests

  run_migrations
end

def setup_oauth_gems
  add_oauth_gems
  setup_figaro
end

def setup_oauth_for_devise
  add_oauth_config_to_devise
  add_oauth_fields_to_user
  add_devise_module_to_users
end

def setup_oauth_controller
  add_oauth_route_and_controller
  create_oauth_controller_code
end

def setup_auth_hash_service
  run "mkdir app/services"
  run "touch app/services/auth_hash_service.rb"
  add_auth_hash_service_code
end

def setup_oauth_tests
  setup_oauth_in_factories_file
  setup_auth_hash_service_spec
  setup_omniauth_callbacks_request_spec
  setup_oauth_support
end

def add_oauth_gems
  inject_into_file "Gemfile", after: "gem 'gem-ctags'\n" do
      <<-RUBY
gem 'figaro'
gem 'omniauth-facebook'
gem 'omniauth-google-oauth2'
      RUBY
    end
  run "bundle update"
  run "bundle install"
end

def setup_figaro
  run "figaro install"

  inject_into_file "config/application.yml" do
      <<-RUBY
development:
  FACEBOOK_OAUTH_ID: "YOUR_FACEBOOK_OAUTH_ID"
  FACEBOOK_OAUTH_SECRET: "YOUR_FACEBOOK_SECRET"
  GOOGLE_OAUTH_ID: "YOUR_GOOGLE_OAUTH_ID"
  GOOGLE_OAUTH_SECRET: "YOUR_GOOGLE_SECRET"
      RUBY
    end
end

def add_oauth_config_to_devise
  inject_into_file "config/initializers/devise.rb",
    after: "# config.omniauth_path_prefix = '/my_engine/users/auth'\n" do
      <<-RUBY
  config.omniauth :facebook, ENV['FACEBOOK_OAUTH_ID'],
    ENV['FACEBOOK_OAUTH_SECRET']

  config.omniauth :google_oauth2, ENV['GOOGLE_OAUTH_ID'],
    ENV['GOOGLE_OAUTH_SECRET'], skip_jwt: true
      RUBY
    end
end

def add_oauth_route_and_controller
  add_oauth_route
  add_oauth_controller
end

def add_oauth_route
  inject_into_file "config/routes.rb", after: "devise_for :users" do
      <<-RUBY
,
  controllers: { :omniauth_callbacks => 'omniauth_callbacks' }
      RUBY
    end
end

def add_oauth_controller
  run "rails g controller omniauth_callbacks"
end

def add_oauth_fields_to_user
  fields = "auth_provider:string auth_uid:string image_url:string"

  run "rails g migration AddOauthFieldsToUsers #{fields}"
  run "spring stop"
  run "rake db:migrate"
end

def add_devise_module_to_users
  inject_into_file "app/models/user.rb", after: ":validatable" do
    <<-RUBY
, :omniauthable,
         :omniauth_providers => [:facebook, :google_oauth2]
    RUBY
  end
end

def create_oauth_controller_code
  run "rm app/controllers/omniauth_callbacks_controller.rb"
  run "touch app/controllers/omniauth_callbacks_controller.rb"
  add_omniauth_callbacks_controller_code
end
