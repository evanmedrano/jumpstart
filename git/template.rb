def add_git
  add_git_commit_hook
  add_git_ci_code
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

def add_git_ci_code
  run "mkdir .github"
  run "mkdir .github/workflows"
  run "touch .github/workflows/ci.yml"

  inject_into_file ".github/workflows/ci.yml" do
    <<-'GIT'
env:
  RUBY_VERSION: 2.7

name: CI
on: [push,pull_request]
jobs:
  rubocop-test:
    name: Rubocop
    runs-on: ubuntu-18.04
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-ruby@v1
        with:
          ruby-version: ${{ env.RUBY_VERSION }}
      - name: Install Rubocop
        run: gem install rubocop
      - name: Check code
        run: rubocop -D -c .rubocop.yml
  rspec-test:
    name: RSpec
    needs: rubocop-test
    runs-on: ubuntu-18.04
    services:
      postgres:
        image: postgres:latest
        env:
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres
          RAILS_ENV: test
        ports:
          - 5432:5432
        options: --health-cmd pg_isready --health-interval 10s --health-timeout 5s --health-retries 5
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-ruby@v1
        with:
          ruby-version: ${{ env.RUBY_VERSION  }}
      - name: Install postgres client
        run: sudo apt-get install libpq-dev
      - name: Install dependencies
        run: |
          gem install bundler
          bundle install
      - name: Create database
        env:
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres
          RAILS_ENV: test
        run: |
          bundle exec rails db:create
          bundle exec rails db:migrate
      - name: Run tests
        env:
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres
          RAILS_ENV: test
        run: rspec --force-color
      - name: Upload coverage results
        uses: actions/upload-artifact@master
        if: always()
        with:
          name: coverage-report
          path: coverage
    GIT
  end
end
