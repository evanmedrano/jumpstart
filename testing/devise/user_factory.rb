def setup_user_factory
  add_sequence_attributes
  add_user_factory_attributes
end

def add_sequence_attributes
  inject_into_file "spec/factories.rb", after: "FactoryBot.define do\n" do
    <<-RUBY
  sequence(:email) do |n|
    "user\#{n}@example.com"
  end

  sequence(:name) do |n|
    "name \#{n}"
  end

    RUBY
  end
end

def add_user_factory_attributes
  inject_into_file "spec/factories.rb", after: "factory :user do\n" do
      <<-RUBY
    email
    name
    password { "foobar123" }
      RUBY
  end
end
