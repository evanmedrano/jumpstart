require_relative "./template"

def add_devise_api_template
  add_devise_jwt_gem
  install_devise
  generate_devise_user_migration
  setup_development_environment
end


def add_devise_jwt_gem
  inject_into_file "Gemfile", after: "'active_model_serializers'\n" do
      <<-RUBY
gem 'devise-jwt'
      RUBY
    end

  run "bundle install"
end

