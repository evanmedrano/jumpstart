def setup_user_spec
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
  context "validations" do
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:password) }

    context "uniqueness" do
      it { should validate_uniqueness_of(:email).case_insensitive }
    end
  end
end
    RUBY
  end
end
