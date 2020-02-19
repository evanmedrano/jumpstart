def stop_spring
  run "spring stop"
end

def add_gems
  inject_into_file 'Gemfile', after: "gem 'bootsnap', '>= 1.1.0', require: false\n" do
      <<-RUBY
gem 'devise'
gem 'devise-bootstrapped'
gem 'bootstrap', '~> 4.3.1'
gem 'jquery-rails'
gem 'font_awesome5_rails'
gem 'gem-ctags'
                RUBY
    end

  # Injects into gems within the :development group
  inject_into_file 'Gemfile', after: "group :development do\n" do
      <<-RUBY
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'pry-rails'
  gem 'spring-commands-rspec'
                            RUBY
  end

  # Injects into gems within the :development, :test group
  inject_into_file 'Gemfile', after: "group :development, :test do\n" do
      <<-RUBY
  gem 'rspec-rails', '~> 4.0.0.beta2'
  gem 'factory_bot_rails', '~> 4.10.0'
                                  RUBY
  end

  # Injects into gems within the :test group
  inject_into_file 'Gemfile', after: "group :test do\n" do
      <<-RUBY
  gem 'shoulda-matchers'
                      RUBY
  end

end

# For testing suite setup
def add_testing
  remove_dir "test"
  generate "rspec:install"
  run "bundle exec spring binstub rspec"

  inject_into_file '.rspec', after: "--require spec_helper\n" do
  "--format documentation"
  end

  inject_into_file "config/application.rb", after: "# the framework and any gems in your application.\n" do
        <<-RUBY
    config.generators do |g|
      g.test_framework :rspec,
      view_specs: false,
      helper_specs: false,
      routing_specs: false
    end
        RUBY
  end

  inject_into_file "spec/rails_helper.rb", after: "RSpec.configure do |config|\n" do <<-RUBY
    config.include FactoryBot::Syntax::Methods
    RUBY
  end

  inject_into_file "spec/rails_helper.rb", after: "# config.filter_gems_from_backtrace(\"gem name\")\nend\n" do <<-RUBY
    Shoulda::Matchers.configure do |config|
      config.integrate do |with|
        with.test_framework :rspec
        with.library :rails
      end
    end
    RUBY
  end

end

# For devise setup
def add_users
  generate "devise:install"

  # Configure devise
  environment "config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }", env: 'development'
  route "root to: 'home#index'"

  # Devise notices are installed via Bootstrap
  run "gem install devise-bootstrapped"

  # Create devise User
  generate :devise, "User",
                              "name",
                              "admin:boolean"

  # Set admin to false
  in_root do
    migration = Dir.glob("db/migrate/*").max_by{ |f| File.mtime(f) }
    gsub_file migration, /:admin/, ":admin, default: false"
  end
end

# Setup bootstrap
def add_bootstrap
  run "rm app/assets/stylesheets/application.css"
  run "touch app/assets/stylesheets/application.scss"

  run "echo \"@import 'bootstrap';\" >> app/assets/stylesheets/application.scss"
end

def add_factories_file
  run "touch spec/factories.rb"

  inject_into_file "spec/factories.rb" do <<-RUBY
FactoryBot.use_parent_strategy = false

FactoryBot.define do

end
    RUBY
  end
end

# Main setup
stop_spring
add_gems

# Finishing touches
after_bundle do
  add_bootstrap
  add_testing
  add_factories_file
  add_users

  stop_spring

  generate "devise:views"
  generate "controller home index"

  # Migrate
  run "rails db:reset"
  run "bundle install"
  run "gem-ctags"
  run "rails db:migrate"
  run "rails db:migrate RAILS_ENV=test"

  git :init
  git add: "."
  git commit: %Q{ -m 'Initial commit' }
end
