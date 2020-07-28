require_relative "base_template"
require_relative "../bootstrap/template"
require_relative "../devise/template"
require_relative "../gemfile/template"
require_relative "../oauth/template"
require_relative "../scss/template"
require_relative "../support/logger"
require_relative "../support/rails_helpers"
require_relative "../testing/template"
require_relative "../testing/devise/template"
require_relative "../views/template"

OPTIONAL_TEMPLATES = %w(bootstrap_and_fontawesome scss devise oauth)
ADD_TEMPLATE_FORMAT = /^add_(.*)_template$/

def add_all_templates?
  if yes?("Add all templates?")
    OPTIONAL_TEMPLATES.each { |template| send("add_#{template}_template") }
  else
    add_templates?
  end
end

def add_templates?
  OPTIONAL_TEMPLATES.each do |template|
    define_singleton_method "add_#{template}_template?" do
      if yes?("Add #{template} template?")
        send("add_#{template}_template")
      end
    end

    send("add_#{template}_template?")
  end
end

def method_missing(method)
  super unless method.match?(ADD_TEMPLATE_FORMAT)

  method.match(ADD_TEMPLATE_FORMAT) do
    log_status "Adding #{$1}."
    send("add_#{$1}") if respond_to?("add_#{$1}")
  end
end

# Main setup
add_gems_template

after_bundle do
  stop_spring
  add_testing_template
  add_all_templates?
  add_slim_template
  setup_database
  run_migrations
  add_gem_ctags
  add_git_commit_hook
  run_git_commands

  log_status "All done! cd #{app_name} to begin. Happy hacking!"
  log_status "Don't forget to update <title> in application.html.slim."
end
