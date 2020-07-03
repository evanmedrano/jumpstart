require_relative "../devise/api_template"
require_relative "../gemfile/api_template"
require_relative "../oauth/template"
require_relative "../testing/template"
require_relative "base_template"

def add_devise_api_template?
  if yes?("Add devise api template?")
    log_status "Setting up devise for api mode."
    stop_spring
    add_devise_api_template
    setup_database
    run_migrations
  end
end

# Main setup
add_gemfile_template

after_bundle do
  stop_spring
  add_testing_template
  add_devise_api_template?
  add_oauth_template?
  bundle_install
  setup_database
  run_migrations
  add_gem_ctags
  run_git_commands
end
