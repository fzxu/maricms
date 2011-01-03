require 'test_helper'

class RegistrationControllerTest < ActionController::TestCase
  tests Devise::RegistrationsController
  #fixtures :users

  def setup
    @mock_warden = OpenStruct.new
    @controller.request.env['warden'] = @mock_warden
    @controller.request.env['devise.mapping'] = Devise.mappings[:user]

    def @mock_warden.authenticated?(resource_name)
      false
    end
  end

  test "should get signup page" do
    get :new
    assert_response :success
    assert_select '#user_user_name', 1
    assert_select '#user_email', 1
    assert_select '#user_password', 1
    assert_select '#user_password_confirmation', 1
    assert_select '#user_submit', 1
  end

  test "should create new user" do
    post :create, :user => {:email => "ark01@test.com", :user_name => "ark01", :password => "123456"}
    #assert_redirected_to :new
    assert_response :success
    
    user_ret = User.all.first
    assert_equal "ark01@test.com", user_ret.email
    assert_equal "ark01", user_ret.user_name
    assert_nil user_ret.confirmed_at
  end
end
