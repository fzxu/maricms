require 'test_helper'

class TabsControllerTest < ActionController::TestCase
  setup do
    @tab = Tab.new(:slug => "home", :name => "Home", :description => "Used for the home page", :hidden => false)
    
    @tabed = Tab.create(:slug => "event", :name => "Event", :description => "Event menu", :hidden => false)
    @page = Page.create(:slug => "home1")
    @tabed.page = @page
    @tabed.param_string = "p=123"
    @tabed.save
  end

	teardown do
		Tab.all.each do |tab|
      tab.delete_descendants
      tab.destroy
		end
		Page.all.each do |page|
			page.destroy
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
      post :create, :tab => @tab.attributes.merge({:page => @page.id})
    end

    #assert_redirected_to tab_path(assigns(:tab))
    assert_redirected_to tabs_path
  end

	test "should create tab with page" do
    assert_difference('Tab.count') do
      post :create, :tab => {:slug => "home1", :name => "Home1", :description => "This is the home page", :param_string => "cat=123",
      	:page => @page.id}
    end

    #assert_redirected_to tab_path(assigns(:tab))
    assert_redirected_to tabs_path
    
    tab_with_page = assigns(:tab)
    tab_with_page.reload
    assert_equal tab_with_page.page.id, @page.id
  end
  
  test "should create tab with specific params" do
  	assert_difference('Tab.count') do
  		post :create, :tab=>{"slug"=>"t1", "name"=>"t1", "page"=>"", "parent"=>"", "param_string"=>"", "ref_url"=>"www.google.com", "open_in_new_window"=>"1"}
  	end
  	
  	assert_redirected_to tabs_path
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
