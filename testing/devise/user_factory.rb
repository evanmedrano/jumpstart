require_relative '../../support/logger'

def setup_user_factory
  log_status "Adding code to the spec/factories.rb file."

  add_user_factory_attributes
end

def add_user_factory_attributes
  inject_into_file "spec/factories.rb", after: "factory :user do\n" do
      <<-RUBY
    email { Faker::Internet.unique.email }
    name { Faker::Name.name }
    password { "foobar123" }
      RUBY
  end
end
