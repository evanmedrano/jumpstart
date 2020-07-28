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
