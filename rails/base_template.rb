require_relative "../support/logger"

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

def add_git_commit_hook
  log_status "Adding prepare-commit-msg hook."

  run "touch .git/hooks/prepare-commit-msg"

  add_git_commit_hook_code

  run "chmod +x .git/hooks/prepare-commit-msg"
end

def add_git_commit_hook_code
  inject_into_file ".git/hooks/prepare-commit-msg" do
    <<-'GIT'
FILE=$1
MESSAGE=$(cat $FILE)
TICKET=[$(git rev-parse --abbrev-ref HEAD |
grep -Eo '^(\w+/)?(\w+[-_])?[0-9]+' |
grep -Eo '(\w+[-])?[0-9]+' | tr "[:lower:]" "[:upper:]")]

if [[ $TICKET == "[]" || "$MESSAGE" == "$TICKET"*  ]];then
  exit 0;
fi

echo "$TICKET $MESSAGE" > $FILE
    GIT
  end
end
