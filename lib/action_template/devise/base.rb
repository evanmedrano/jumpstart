require_relative "../support/rails_helpers"
require_relative "../testing/devise/template"
require_relative "../testing/devise/jwt/template"

def add_devise
  stop_spring

  add_devise_gem
  install_devise
  setup_devise
  add_devise_testing_template
  add_devise_test_helpers

  setup_database
  run_migrations
end

def add_devise_gem
  inject_into_file "Gemfile", after: "'gem-ctags'\n" do
      <<-RUBY
gem 'devise'
      RUBY
    end

  run "bundle install"
end

def install_devise
  run "rails g devise:install"
end

def setup_devise
  generate_devise_user_migration
  generate_devise_views
  generate_static_pages_controller
  setup_development_environment
  setup_root_route
  add_flash_messages_to_application_layout
end

def generate_devise_user_migration
  generate :devise, "User", "name", "admin:boolean"

  in_root do
    migration = Dir.glob("db/migrate/*").max_by{ |f| File.mtime(f) }
    gsub_file migration, /:admin/, ":admin, default: false"
  end
end

def setup_development_environment
  url_options = "{ host: 'localhost', port: 3000 }"

  environment "config.action_mailer.default_url_options = #{url_options}", env: 'development'
end

def setup_root_route
  route "root to: 'static_pages#home'"
end

def add_flash_messages_to_application_layout
  inject_into_file "app/views/layouts/application.html.erb", after: "<body>\n" do
    <<-RUBY
    <% if flash.any? %>
      <% flash.each do |key, value| %>
        <div class="flash"><%= value.html_safe %></div>
      <% end %>
    <% end %>
    RUBY
  end
end

def generate_devise_views
  generate "devise:views"
end

def generate_static_pages_controller
  generate "controller static_pages home"
end
