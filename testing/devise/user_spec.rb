require_relative '../../support/logger'

def setup_user_spec
  log_status "Adding tests to the spec/models/user_spec.rb file."

  start_with_fresh_user_spec_file
  add_user_spec_code
end

def start_with_fresh_user_spec_file
  run "rm spec/models/user_spec.rb"
  run "touch spec/models/user_spec.rb"
end

def add_user_spec_code
  inject_into_file "spec/models/user_spec.rb" do
    <<-RUBY
require 'rails_helper'

describe User do
  describe "validations" do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_presence_of(:password) }
  end
end
    RUBY
  end
end
