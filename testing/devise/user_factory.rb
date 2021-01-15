require_relative '../../support/logger'

def setup_user_factory
  run "rm -rf spec/factories"

  log_status "Adding code to the spec/factories.rb file."

  add_user_factory_attributes
end

def add_user_factory_attributes
  inject_into_file "spec/factories.rb", after: "FactoryBot.define do\n" do
      <<-RUBY
  factory :user do
    email { Faker::Internet.unique.email }
    password { "foobar123" }
  end
      RUBY
  end
end
