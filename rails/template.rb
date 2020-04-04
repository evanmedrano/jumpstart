require_relative "../bootstrap/template"
require_relative "../devise/template"
require_relative "../gemfile/template"
require_relative "../oauth/template"
require_relative "../scss/template"
require_relative "../testing/template"

def add_gemfile_template
  add_gems
end

def add_testing_template
  add_testing
end

def add_templates?
  add_bootstrap_template?
  add_scss_template?
  add_devise_template?
  add_oauth_template?
end

def add_bootstrap_template?
  if yes?("Add bootstrap and fontawesome template?")
    add_bootstrap_and_fontawesome_template
  end
end

def add_scss_template?
  if yes?("Add scss template?")
    add_scss_template
  end
end

def add_devise_template?
  if yes?("Add devise template?")
    stop_spring
    add_devise_template
    setup_database
    run_migrations
  end
end

def add_oauth_template?
  if yes?("Add oauth template?")
    add_oauth_template
    run_migrations
  end
end

def stop_spring
  run "spring stop"
end

def setup_database
  rails_command "db:drop && rails db:create"
end

def run_migrations
  rails_command "db:migrate && rails db:migrate RAILS_ENV=test"
end

def bundle_install
  run "bundle install"
end

def add_gem_ctags
  run "gem ctags"
end

def run_git_commands
  git :init
  git :ctags
  git add: "."
  git commit: %Q{ -m 'Initial commit' }
  run "git flow init"
end

# Main setup
add_gemfile_template

after_bundle do
  stop_spring
  add_testing_template
  add_templates?
  setup_database
  run_migrations
  add_gem_ctags
  run_git_commands
end
