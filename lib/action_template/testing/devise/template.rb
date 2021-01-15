require_relative 'jwt/template'
require_relative 'user_factory'
require_relative 'user_spec'

def add_devise_testing_template
  setup_user_factory
  setup_user_spec
end
