def setup_oauth_in_factories_file
  add_oauth_attributes_to_user_factory
  add_oauth_traits_to_user_factory
end

def add_oauth_attributes_to_user_factory
  inject_into_file "spec/factories.rb", after: "email\n" do
      <<-RUBY
    image_url { "test_image.png" }
      RUBY
  end
end

def add_oauth_traits_to_user_factory
  add_facebook_auth_trait
  add_google_auth_trait
end

def add_facebook_auth_trait
  inject_into_file "spec/factories.rb", after: "{ \"foobar123\" }\n" do
      <<-RUBY

    trait :with_facebook_auth do
      auth_provider { "facebook" }
      auth_uid { "12345" }
      email { "facebook_oauth@example.com" }
      image_url { "facebook_oauth.png" }
    end
      RUBY
  end
end

def add_google_auth_trait
  inject_into_file "spec/factories.rb", after: "{ \"foobar123\" }\n" do
      <<-RUBY

    trait :with_google_auth do
      auth_provider { "google_oauth2" }
      auth_uid { "12345" }
      email { "google_oauth2@example.com" }
      image_url { "google_oauth.png" }
    end
      RUBY
  end
end
