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
    # users = User.find(:all)
    # assert_equal users.size, 2
    # users.each do |user|
    #   assert_equal user.user_name, "ark01"
    # end
    post :create, :user => {:email => "ark01@test.com", :user_name => "ark01", :password => "123456"}
    assert_redirected_to :new
  end
end
