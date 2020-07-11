require_relative "../testing/template"
require_relative "jwt_template"
require_relative "template"

def add_devise_api_template
  add_devise_api_gems
  install_devise
  generate_devise_user_migration
  setup_development_environment
  setup_figaro_for_devise_jwt
  add_devise_jwt_template
  add_devise_testing_template
  add_devise_jwt_testing_template
  add_devise_test_helpers
end


def add_devise_api_gems
  inject_into_file "Gemfile", after: "'active_model_serializers'\n" do
      <<-RUBY
gem 'devise'
gem 'devise-jwt'
gem 'figaro'
      RUBY
    end

  run "bundle install"
end

def setup_figaro_for_devise_jwt
  run "bundle exec figaro install"

  inject_into_file "config/application.yml" do
    <<-RUBY
DEVISE_JWT_SECRET_KEY:
    RUBY
  end
end
