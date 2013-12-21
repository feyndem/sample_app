require 'spec_helper'

describe "AuthenticationPages" do
  
  subject { page }
  
  describe "signin page" do
    before { visit signin_path }
    it { should have_content("Sign In")}
    it { should have_title("Sign In") }
  end
  
  describe "signin" do
    before { visit signin_path }
    
    describe "with invalid information" do
      before { click_button "Sign In" }
      it { should have_title("Sign In") }
      it { should have_error_message("Invalid") }
      
      describe "after visiting another page" do
        before { click_link "Home" }
        it { should_not have_selector('div.alert-box', text: "Invalid") }
      end
    end
    
    describe "with valid information" do
      let(:user) { FactoryGirl.create(:user) }
      before { valid_signin(user) }
      it { should have_title(user.name) }
      it { should have_link('Profile', href: user_path(user)) }
      it { should have_link('Sign Out', href: signout_path) }
      it { should_not have_link('Sign In', href: signin_path) }
    end
    
  end  
  
  describe "with valid information" do
    let(:user) { FactoryGirl.create(:user) }
    before { sign_in(user) }
    
    it { should have_title(user.name) }
    it { should have_link('Profile', href: user_path(user)) }
    it { should have_link('Settings', href: edit_user_path(user)) }
    it { should have_link('Sign Out', href: signout_path) }
    it { should_not have_link('Sign In', href: signin_path) }
    it { should have_link('Users', href: users_path) }
    
  end    
  
  describe "authorization" do
    
    describe "for non-signed-in users" do
      let(:user) { FactoryGirl.create(:user) }
      
      describe "in the Users controller" do
        
        describe "when attempting to visit a protected page" do
          before do
            visit edit_user_path(user)
            fill_in "Email", with: user.email
            fill_in "Password", with: user.password
            click_button "Sign In"          
          end
          describe "after signing in" do
            it "should render the desired protected page" do
              expect(page).to have_title("Edit user")
            end
          end
        end
        
        describe "submitting to the update action" do
          before { patch user_path(user) }
          specify { expect(response).to redirect_to(signin_path) }
        end        
        
        describe "visiting the edit page" do
          before { visit edit_user_path(user) }
          it { should have_title('Sign In') }
        end  
        
        describe "visiting the user index" do
          before { visit users_path }
          it { should have_title('Sign In') }
        end
        
        describe "visitng the following page" do
          before { visit following_user_path(user) }
          it { should have_title('Sign In') }
        end
        
        describe "visitng the followers page" do
          before { visit followers_user_path(user) }
          it { should have_title('Sign In') }
        end        
                      
      end
      
      describe "in the Microposts controller" do
        describe "submitting to the create action" do
          before { post microposts_path }
          specify { expect(response).to redirect_to(signin_path) }
        end
        describe "submitting to the destroy action" do
          before { delete micropost_path(FactoryGirl.create(:micropost)) }
          specify { expect(response).to redirect_to(signin_path) }
        end
      end
    end
    
    describe "as wrong user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:wrong_user) { FactoryGirl.create(:user, email: "wronguser@example.com") }
      before { sign_in user, no_capybara: true }
      
      describe "submitting GET request to the Users#edit action" do
        before { get edit_user_path(wrong_user) }
        specify { expect(response.body).not_to match(full_title('Edit user')) }
        specify { expect(response).to redirect_to(root_url) }
      end
      
    end
    
    describe "as non-admin user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:non_admin) { FactoryGirl.create(:user) }
      before { sign_in non_admin, no_capybara: true }
      
      describe "submitting a DELETE request to the Users#destroy action" do
        before { delete user_path(user) }
        specify { expect(response).to redirect_to root_url }
      end
      
    end
    
  end
  
end
