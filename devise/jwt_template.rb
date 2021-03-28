require_relative "../support/logger"

def add_devise_jwt_template
  update_devise_config_file
  add_jwt_blacklist
  add_revocation_strategy_to_user_model
  setup_controllers_for_devise_jwt
end

def add_revocation_strategy_to_user_model
  log_status "Adding recovation strategy to user model."

  inject_into_file "app/models/user.rb", after: "validatable" do
    <<-RUBY
, :jwt_authenticatable,
         jwt_revocation_strategy: JwtBlacklist
    RUBY
  end
end

def add_jwt_blacklist
  log_status "Adding JwtBlacklist model."

  create_jwt_blacklist_migration_file
  create_jwt_blacklist_model
end

def update_devise_config_file
  log_status "Updating devise initializers."

  inject_into_file "config/initializers/devise.rb",
    after: "# config.sign_in_after_change_password = true\n" do
    <<-RUBY

  config.jwt do |jwt|
    jwt.secret = ENV['DEVISE_JWT_SECRET_KEY']
    jwt.dispatch_requests = [
      ['POST', %r{^/login$}]
    ]
    jwt.revocation_requests = [
      ['DELETE', %r{^/logout$}]
    ]
    jwt.expiration_time = 1.day.to_i
  end
    RUBY
  end
end

def setup_controllers_for_devise_jwt
  log_status "Setting up controllers for devise jwt."

  add_registrations_controller
  add_sessions_controller
  update_application_controller
  update_routes_file
end

def create_jwt_blacklist_migration_file
  run "rails g migration CreateJwtBlacklists jti:string:index exp:datetime"

  # migration_file = Dir.glob("db/migrate/*").last

  # inject_into_file migration_file, after: "|t|\n" do
  #   <<-RUBY
  #     t.datetime :exp, null: false
  #   RUBY
  # end

  # run "rails g migration AddIndexToJwtBlacklists jti:string:index"
  # inject_into_file migration_file, after: "t.timestamps\nend\n" do
  #   <<-RUBY
  #   add_index :jwt_blacklists, :jti
  #   RUBY
  # end
end

def create_jwt_blacklist_model
  run "touch app/models/jwt_blacklist.rb"

  inject_into_file "app/models/jwt_blacklist.rb" do
    <<-RUBY
class JwtBlacklist < ApplicationRecord
  include Devise::JWT::RevocationStrategies::Denylist

  self.table_name = :jwt_blacklists
end
    RUBY
  end
end

def add_registrations_controller
  run "touch app/controllers/registrations_controller.rb"

  inject_into_file "app/controllers/registrations_controller.rb" do
    <<-RUBY
class RegistrationsController < Devise::RegistrationsController
  respond_to :json

  def create
    build_resource(sign_up_params)

    resource.save
    render_resource(resource)
  end
end
    RUBY
  end
end

def add_sessions_controller
  run "touch app/controllers/sessions_controller.rb"

  inject_into_file "app/controllers/sessions_controller.rb" do
    <<-RUBY
class SessionsController < Devise::SessionsController
  respond_to :json

  private

  def respond_with(resource, _opts = {})
    render json: resource
  end

  def respond_to_on_destroy
    head :no_content
  end
end
    RUBY
  end
end

def update_application_controller
  inject_into_file "app/controllers/application_controller.rb", after: "API\n" do
    <<-RUBY
  def render_resource(resource)
    if resource.errors.empty?
      render json: resource
    else
      validation_error(resource)
    end
  end

  private

  def validation_error(resource)
    render json: {
      errors: [
        {
          status: 400,
          title: "Bad Request",
          detail: resource.errors,
          code: 100
        }
      ]
    }, status: :bad_request
  end
    RUBY
  end
end

def update_routes_file
  inject_into_file "config/routes.rb", after: ":users" do
    <<-RUBY
,
             path: '',
             path_names: {
               sign_in: 'login',
               sign_out: 'logout',
               registration: 'signup'
             },
             controllers: {
               sessions: 'sessions',
               registrations: 'registrations'
             }
    RUBY
  end
end
