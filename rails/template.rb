require_relative "base_template"
require_relative "../bootstrap/template"
require_relative "../devise/template"
require_relative "../gemfile/template"
require_relative "../git/template"
require_relative "../oauth/template"
require_relative "../rubocop/template"
require_relative "../scss/template"
require_relative "../support/logger"
require_relative "../support/rails_helpers"
require_relative "../testing/template"
require_relative "../testing/devise/template"
require_relative "../views/template"

OPTIONAL_TEMPLATES = %w(bootstrap_and_fontawesome scss devise oauth)

def add_all_templates?
  if yes?("Add all templates?")
    OPTIONAL_TEMPLATES.each { |template| send("add_template", template) }
  else
    add_templates?
  end
end

def add_templates?
  OPTIONAL_TEMPLATES.each do |template|
    define_singleton_method "add_#{template}_template?" do
      if yes?("Add #{template} template?")
        send("add_template", template)
      end
    end

    send("add_#{template}_template?")
  end
end

# Main setup
add_template "gems"

after_bundle do
  stop_spring
  add_template "testing"
  add_all_templates?
  add_template "slim"
  setup_database
  run_migrations
  add_template "rubocop"
  add_gem_ctags
  add_template "git"
  run_git_commands

  log_status "All done! cd #{app_name} to begin. Happy hacking!"
  log_status "Don't forget to update <title> in application.html.slim."
end
