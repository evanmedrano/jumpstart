def add_git
  add_git_commit_hook
  add_git_workflow_files_and_code
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

def add_git_workflow_files_and_code
  run "mkdir .github"
  run "mkdir .github/workflows"
  run "touch .github/workflows/rspec.yml"
  run "touch .github/workflows/rubocop.yml"
  run "touch config/database.yml.ci"

  add_git_rubocop_code
  add_git_rspec_code
  add_ci_db_code
end

def add_git_rubocop_code
  inject_into_file ".github/workflows/rubocop.yml" do
    <<-'GIT'
env:
  RUBY_VERSION: 2.7

name: Rubocop
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
        run: gem install rubocop rubocop-rails rubocop-rspec
      - name: Check code
        run: rubocop -D -c .rubocop.yml
    GIT
  end
end

def add_git_rspec_code
  inject_into_file ".github/workflows/rspec.yml" do
    <<-'GIT'
env:
  RUBY_VERSION: 2.7

name: RSpec
on: [push,pull_request]
jobs:
  rspec-test:
    name: RSpec
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
          yarn install
      - name: Bundle install
        run: bundle install
      - name: Create database
        run: |
          cp config/database.yml.ci config/database.yml
          bundle exec rails db:create
          bundle exec rails db:schema:load
        env:
          POSTGRES_DB: ci_db_test
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres
          RAILS_ENV: test
      - name: Run tests
        env:
          POSTGRES_DB: ci_db_test
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres
          RAILS_ENV: test
          DEVISE_JWT_SECRET_KEY: ${{ secrets.DEVISE_JWT_SECRET_KEY }}
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

def add_ci_db_code
  inject_into_file "config/database.yml.ci" do
    <<-'GIT'
test:
  adapter: postgresql
  host: localhost
  encoding: unicode
  database: <%= ENV['POSTGRES_DB'] %>
  pool: 20
  username: <%= ENV['POSTGRES_USER'] %>
  password: <%= ENV['POSTGRES_PASSWORD'] %>
    GIT
  end
end
