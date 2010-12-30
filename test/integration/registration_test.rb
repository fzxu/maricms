require 'test_helper'

class RegistrationTest < ActionController::IntegrationTest
  def setup
    #delete the user table
    users = User.find(:all)
    users.each do |user|
      user.destroy
    end
  end
  
  test 'a guest user should be able to sign up successfully' do
    ark01 = create_user
    
    assert_response :success
    assert_template "new"

    assert_equal ark01.email, 'ark01@test.com'
    assert !ark01.confirmed?
    assert_nil ark01.confirmed_at
  end
  
  test "user should be able to confirm his registration" do
    ark01 = create_user
    activate_user ark01
    
    ark01.reload
    assert_not_nil ark01.confirmed_at
  end
  
  test "confirmed user can login via user_name" do
    ark01 = create_user
    activate_user ark01
    
    post_via_redirect user_session_path, :user => {
      :login => "ark01",
      :password => "123456"
    }
    
    assert_redirect_to "/"
  end

  test "confirmed user can login via email" do
    ark01 = create_user
    activate_user ark01
    
    post_via_redirect user_session_path, :user => {
      :login => "ark01@test.com",
      :password => "123456"
    }
    
    assert_redirect_to "/"
  end
  
  test "non-existing user can not login" do
    ark01 = create_user
    activate_user ark01
    
    post_via_redirect user_session_path, :user => {
      :login => "ark02@test.com",
      :password => "123456"
    }
    
    assert_redirect_to user_session_path
  end
  
  private
  
  def create_user
    post_via_redirect user_registration_path, :user => {
      :email => "ark01@test.com",
      :user_name => "ark01",
      :password => "123456"
    }
    user = User.find(:first)
  end
  
  def activate_user user
    get user_confirmation_path, :confirmation_token => user.confirmation_token
  end
end