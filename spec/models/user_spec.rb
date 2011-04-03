require "spec_helper"

describe User do
  
  after(:each) do
    User.destroy_all
  end
  
  context "make it possible to login by username or email" do
    it "should be invalid if there is no username" do
      user = User.new
      user.should have(1).error_on(:user_name)
      user.should have(1).error_on(:email)
      user.should have(1).error_on(:password)
    end
    
    it "should not have duplicated user name" do
      user1 = User.create(:user_name => "arkxu", :email => "arkxu22222@test.com", :password => "123456")
      user1.should have(0).error_on(:user_name)
      user1.should have(0).error_on(:email)
      user1.should have(0).error_on(:password)      

      user2 = User.create(:user_name => "arkxu", :email => "arkxu22222@test.com", :password => "123456")
      user2.should have(1).error_on(:user_name)
      user2.should have(0).error_on(:email)
      user2.should have(0).error_on(:password)
    end
  end
end