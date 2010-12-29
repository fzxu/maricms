require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  def setup
    # clear the table
    users = User.find(:all)
    users.each do |user|
      user.delete
    end
  end
  
  def teardown
    
  end
  
  test "check an empty user and it's validation" do
    user = User.new
    assert user.invalid?
    assert user.errors[:email].any?
    assert user.errors[:user_name].any?
    assert user.errors[:password].any?
  end
  
  test "user name should not be duplicate" do
    user1 = User.new(:user_name => "arkxu", :email => "arkxu22222@test.com", :password => "123456")
    user1.save
    assert user1.valid?
    user2 = User.new(:user_name => "arkxu", :email => "arkxu2@test.com", :password => "123456")
    assert user2.invalid?
    assert user2.errors[:user_name].any?
  end
  
  test "user name should not be empty" do
    user = User.new(:email => "arkxu22222@test.com", :password => "123456")
    assert user.invalid?
  end
  
  test "user name format testing" do
    #need to do more user name format testing
  end
end
