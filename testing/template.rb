require_relative "../support/logger"

# For testing suite setup
def add_testing
  setup_rspec
  setup_rspec_generators
  setup_rails_helper
  setup_factories_file
end

def setup_rspec
  remove_dir "test"
  generate "rspec:install"
  run "bundle exec spring binstub rspec"

  inject_into_file ".rspec", after: "--require spec_helper\n" do
  "--format documentation"
  end
end

def setup_rspec_generators
  inject_into_file "config/application.rb", after: "# the framework and any gems in your application.\n" do
        <<-RUBY
    config.generators do |g|
      g.test_framework :rspec,
      view_specs: false,
      routing_specs: false
    end
        RUBY
  end
end

def setup_rails_helper
  add_factorybot_test_helpers
  add_shoulda_gem_configuration
end

def add_factorybot_test_helpers
  inject_into_file "spec/rails_helper.rb", after: "RSpec.configure do |config|\n" do
    <<-RUBY
  config.include FactoryBot::Syntax::Methods
    RUBY
  end
end

def add_devise_test_helpers
  log_status "Adding Devise and FactoryBot test helpers."

  inject_into_file "spec/rails_helper.rb", after: "FactoryBot::Syntax::Methods\n" do
    <<-RUBY
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Devise::Test::IntegrationHelpers, type: :feature
    RUBY
  end
end

def add_shoulda_gem_configuration
  inject_into_file "spec/rails_helper.rb", after: "# config.filter_gems_from_backtrace(\"gem name\")\nend\n" do
    <<-RUBY

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
    RUBY
  end
end

def setup_factories_file
  add_factories_file
  add_factories_file_boilerplate_code
end

def add_factories_file
  run "touch spec/factories.rb"
end

def add_factories_file_boilerplate_code
  inject_into_file "spec/factories.rb" do
    <<-RUBY
require 'faker'

FactoryBot.use_parent_strategy = false

FactoryBot.define do

end
    RUBY
  end
end
