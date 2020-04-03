def stop_spring
  run "spring stop"
end

def add_gems
  inject_into_file 'Gemfile', after: "gem 'bootsnap', '>= 1.4.2', require: false\n" do
      <<-RUBY
gem 'devise'
gem 'devise-bootstrapped'
gem 'bootstrap', '~> 4.3.1'
gem 'jquery-rails'
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
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Devise::Test::IntegrationHelpers, type: :feature
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
  generate :devise, "User", "name", "admin:boolean"

  # Set admin to false
  in_root do
    migration = Dir.glob("db/migrate/*").max_by{ |f| File.mtime(f) }
    gsub_file migration, /:admin/, ":admin, default: false"
  end
end

# Setup bootstrap
def add_bootstrap_and_fontawesome
  run "yarn add bootstrap jquery popper.js @fortawesome/fontawesome-free"
  run "mkdir app/javascript/stylesheets"
  run "touch app/javascript/stylesheets/application.scss"
  run 'echo "@import \"~bootstrap/scss/bootstrap\";" >> app/javascript/stylesheets/application.scss'

  inject_into_file "config/webpack/environment.js",
    after: "const { environment } = require('@rails/webpacker')\n" do <<-RUBY
const webpack = require("webpack")

environment.plugins.append("Provide", new webpack.ProvidePlugin({
  $: 'jquery',
  jQuery: 'jquery',
  Popper: ['popper.js', 'default']
}))
  RUBY
end

  inject_into_file "app/javascript/packs/application.js",
    after: "require(\"channels\")\n" do <<-RUBY

import "@fortawesome/fontawesome-free/js/all"
import "bootstrap"
import "../stylesheets/application"

document.addEventListener("turbolinks:load", () => {
  $('[data-toggle="tooltip"]').tooltip()
  $('[data-toggle="popover"]').popover()
})
  RUBY
end

  inject_into_file "app/views/layouts/application.html.erb",
    after: "<%= stylesheet_link_tag 'application', media: 'all', 'data-turbolinks-track': 'reload' %>\n" do <<-RUBY
    <%= stylesheet_pack_tag 'application', media: 'all', 'data-turbolinks-track': 'reload' %>
  RUBY
end
end

def add_scss
  add_scss_directories
  add_scss_files
  import_scss_files
end

def add_scss_directories
  add_scss_directory "abstracts"
  add_scss_directory "base"
  add_scss_directory "components"
  add_scss_directory "layouts"
  add_scss_directory "pages"
end

def add_scss_files
  add_scss_file_to_directory("_variables", "abstracts")

  add_scss_file_to_directory("_base", "base")
  add_scss_file_to_directory("_typography", "base")
  add_scss_file_to_directory("_utilities", "base")

  add_scss_file_to_directory("_footer", "layouts")
  add_scss_file_to_directory("_header", "layouts")
end

def import_scss_files
  apply_page_reset_styling

  inject_into_file "app/javascript/stylesheets/application.scss",
    after: "@import \"~bootstrap/scss/bootstrap\";\n" do <<-RUBY
@import "@fortawesome/fontawesome-free";

@import "abstracts/variables";

@import "base/base";
@import "base/typography";
@import "base/utilities";

@import "layouts/footer";
@import "layouts/header";
  RUBY
end
end

def apply_page_reset_styling
  inject_into_file "app/javascript/stylesheets/base/_base.scss" do
    <<-RUBY
*,
*::before,
*::after {
  box-sizing: inherit;
  margin: 0;
  padding: 0;
}

html {
  font-size: 62.5%;
}

body {
  box-sizing: border-box;
}
  RUBY
end
end

def add_scss_directory(directory)
  run "mkdir app/javascript/stylesheets/#{directory}"
end

def add_scss_file_to_directory(file, directory)
  run "touch app/javascript/stylesheets/#{directory}/#{file}.scss"
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
  add_bootstrap_and_fontawesome
  add_scss
  add_testing
  add_factories_file
  add_users

  #stop_spring

  generate "devise:views"
  generate "controller home index"

  # Migrate
  run "bundle install"
  run "rails db:drop && rails db:create"
  run "rails db:migrate && rails db:migrate RAILS_ENV=test"

  # Git commands
  git :init
  run "git ctags"
  git add: "."
  git commit: %Q{ -m 'Initial commit' }
  run "git flow init"
end
