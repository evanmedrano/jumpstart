require_relative "base_template"
require_relative "../bootstrap/template"
require_relative "../devise/template"
require_relative "../gemfile/template"
require_relative "../oauth/template"
require_relative "../scss/template"
require_relative "../support/logger"
require_relative "../testing/template"
require_relative "../testing/devise/template"
require_relative "../views/template"

def add_templates?
  add_bootstrap_template?
  add_scss_template?
  add_devise_template?
  add_oauth_template?
end

def add_bootstrap_template?
  if yes?("Add bootstrap and fontawesome template?")
    log_status "Adding bootstrap and fontawesome files."
    add_bootstrap_and_fontawesome_template
  end
end

def add_scss_template?
  if yes?("Add scss template?")
    log_status "Adding scss files."
    add_scss_template
  end
end

def add_devise_template?
  if yes?("Add devise template?")
    log_status "Setting up devise."
    stop_spring
    add_devise_template
    setup_database
    run_migrations
  end
end

def add_oauth_template?
  if yes?("Add oauth template?")
    log_status "Adding oauth files."
    add_oauth_template
    run_migrations
  end
end

# Main setup
add_gemfile_template

after_bundle do
  stop_spring
  add_testing_template
  add_templates?
  add_slim_template
  setup_database
  run_migrations
  add_gem_ctags
  add_git_commit_hook
  run_git_commands

  log_status "All done! cd #{app_name} to begin. Happy hacking!"
end
