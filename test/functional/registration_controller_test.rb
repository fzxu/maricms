require 'test_helper'

class RegistrationControllerTest < ActionController::TestCase
  tests Devise::RegistrationsController
  
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
end