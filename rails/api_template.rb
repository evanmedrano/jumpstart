require_relative "../gemfile/api_template"
require_relative "../testing/template"

def add_gemfile_template
  add_gems
end

def add_testing_template
  add_testing
end

def stop_spring
  run "spring stop"
end

def setup_database
  rails_command "db:create"
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
  bundle_install
  setup_database
  run_migrations
  add_gem_ctags
  run_git_commands
end
