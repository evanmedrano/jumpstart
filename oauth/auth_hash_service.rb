def add_auth_hash_service_code
  inject_into_file 'app/services/auth_hash_service.rb' do
    <<-RUBY
# frozen_string_literal: true

class AuthHashService
  def initialize(auth_hash)
    @auth_hash = auth_hash
  end

  def find_or_create_user_from_auth_hash
    user_from_auth_hash || user_from_email || create_from_auth_hash
  end

  private

  attr_accessor :auth_hash

  def user_from_auth_hash
    User.find_by(
      auth_provider: auth_hash['provider'],
      auth_uid: auth_hash['uid']
    )
  end

  def user_from_email
    email_user.tap do |user|
      update_provider_info(user)
    end
  end

  def create_from_auth_hash
    User.create(
      email: auth_info['email'],
      image_url: auth_info['image'],
      password: Devise.friendly_token[0, 20],
      auth_provider: auth_hash['provider'],
      auth_uid: auth_hash['uid']
    )
  end

  def update_provider_info(user)
    return unless user.present?

    user.update(
      auth_provider: auth_hash['provider'],
      auth_uid: auth_hash['uid']
    )
  end

  def email_user
    User.find_by(email: auth_info['email'])
  end

  def auth_info
    auth_hash.fetch('info', {})
  end
end
    RUBY
  end
end
