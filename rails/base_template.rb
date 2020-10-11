require_relative "../support/logger"

def add_template(template)
  template_name = template.split("_").join(" ")

  log_status "Adding #{template_name} template."
  send("add_#{template}")
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
