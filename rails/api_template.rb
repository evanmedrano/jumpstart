require_relative "base_template"
require_relative "../devise/api_template"
require_relative "../gemfile/api_template"
require_relative "../support/logger"
require_relative "../testing/template"
require_relative "../testing/devise/template"

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
  bundle_install
  setup_database
  run_migrations
  add_gem_ctags
  add_git_commit_hook
  run_git_commands

  log_status "All done! cd #{app_name} to begin. Happy hacking!"
  log_status "Make sure to generate a rake secret for devise jwt."
  log_status "Don't forget to update devise navigational_formats to '[]'."
end
