require 'spec_helper'

describe "Users Pages" do
  subject { page }
  describe "sign up page" do
    before { visit signup_path}
    it { should have_content('Sign Up') }
    it { should have_title(full_title('Sign Up')) }
  end
end
