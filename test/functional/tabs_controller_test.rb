require 'test_helper'

class TabsControllerTest < ActionController::TestCase
  setup do
    @tab = Tab.new(:slug => "home", :name => "Home", :description => "Used for the home page", :hidden => false)
    
    @tabed = Tab.create(:slug => "event", :name => "Event", :description => "Event menu", :hidden => false)
  end

	teardown do
		Tab.all.each do |tab|
			tab.destroy
		end	
	end
	
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tabs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tab" do
    assert_difference('Tab.count') do
      post :create, :tab => @tab.attributes
    end

    assert_redirected_to tab_path(assigns(:tab))
  end

  test "should show tab" do
    get :show, :id => @tabed.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @tabed.to_param
    assert_response :success
  end

  test "should update tab" do
    put :update, :id => @tabed.to_param, :tab => {:slug => "event2", :name => "Event2", :description => "Event menu", :hidden => true}
    assert_redirected_to tab_path(assigns(:tab))
    @tabed.reload
    assert_equal @tabed.slug, "event2"
    assert_equal @tabed.name, "Event2"
    assert_equal @tabed.description, "Event menu"
    assert @tabed.hidden
  end

  test "should destroy tab" do
    assert_difference('Tab.count', -1) do
      delete :destroy, :id => @tabed.to_param
    end

    assert_redirected_to tabs_path
  end
end
