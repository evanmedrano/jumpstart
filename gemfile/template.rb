def add_gems
  add_default_group_gems
  add_development_group_gems
  add_development_and_test_group_gems
  add_test_group_gems
end

def add_default_group_gems
  inject_into_file "Gemfile", after: "'bootsnap', '>= 1.4.2', require: false\n" do
      <<-RUBY
gem 'faker', :git => 'https://github.com/faker-ruby/faker.git', :branch => 'master'
gem 'gem-ctags'
gem 'slim'
gem 'slim-rails'
      RUBY
    end
end

def add_development_group_gems
  inject_into_file "Gemfile", after: "group :development do\n" do
      <<-RUBY
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'pry-rails'
  gem 'spring-commands-rspec'
      RUBY
  end
end

def add_development_and_test_group_gems
  inject_into_file "Gemfile", after: "group :development, :test do\n" do
      <<-RUBY
  gem 'factory_bot_rails', '~> 4.10.0'
  gem 'rspec-rails', '~> 4.0.0.beta2'
      RUBY
  end
end

def add_test_group_gems
  inject_into_file "Gemfile", after: "group :test do\n" do
      <<-RUBY
  gem 'shoulda-matchers'
      RUBY
  end
end
