module ActionTemplate
  autoload Bootstrap::Base, 'action_template/bootstrap/base'
  autoload Devise::Base,    'action_template/devise/base'
  autoload Gemfile::Base,   'action_template/gemfile/base'
  autoload Git::Base,       'action_template/git/base'
  autoload Oauth::Base,     'action_template/oauth/base'
  autoload Rails::Base,     'action_template/rails/base'
  autoload Rubocop::Base,   'action_template/rubocop/base'
  autoload Scss::Base,      'action_template/scss/base'
  autoload Testing::Base,   'action_template/testing/base'
  autoload View::Base,      'action_template/view/base'
end
