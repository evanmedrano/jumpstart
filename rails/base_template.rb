def add_gemfile_template
  log_status "Adding gems."
  add_gems
end

def add_testing_template
  log_status "Adding test configuration."
  add_testing
end

def add_oauth_template?
  if yes?("Add oauth template?")
    log_status "Adding oauth files."
    add_oauth_template
    run_migrations
  end
end

def stop_spring
  log_status "Stopping spring."
  run "spring stop"
end

def setup_database
  log_status "Setting up the database."
  rails_command "db:drop && rails db:create"
end

def run_migrations
  log_status "Running migrations."
  rails_command "db:migrate && rails db:migrate RAILS_ENV=test"
end

def bundle_install
  log_status "Bundling Gemfile."
  run "bundle install"
end

def add_gem_ctags
  log_status "Adding gem ctags."
  run "gem ctags"
end

def run_git_commands
  log_status "Running git commands."
  git :init
  git :ctags
  git add: "."
  git commit: %Q{ -m 'Initial commit' }
  run "git flow init"
end

def log_status(text)
  puts <<-LOG
================================================================================
#{text.center(80)}
================================================================================
      LOG
end

