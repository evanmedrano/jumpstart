def setup_oauth_in_factories_file
  add_oauth_attributes_to_user_factory
  add_oauth_trait_to_user_factory
end

def add_oauth_attributes_to_user_factory
  inject_into_file "spec/factories.rb", after: "email\n" do
      <<-RUBY
    image_url { "test_image.png" }
      RUBY
  end
end

def add_oauth_trait_to_user_factory
  inject_into_file "spec/factories.rb", after: "{ \"foobar123\" }\n" do
      <<-RUBY

    trait :with_omniauth do
      transient do
        provider { "facebook" }
      end

      after(:build) do |user, evaluator|
        omniauth = Faker::Omniauth.send(evaluator.provider.to_sym)

        user.auth_provider = omniauth[:provider]
        user.auth_uid = omniauth[:uid]
        user.image_url = omniauth[:info][:image]
      end
    end
      RUBY
  end
end
