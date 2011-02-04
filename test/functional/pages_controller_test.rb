require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  setup do
    @page = Page.create(:slug => "home", :title => "Home", :js_paths => ["accordion.js", "event/cool.js"],
                     :page_metas => [
                       {
                         :http_equiv => "Content-Type",
                         :content => "text/html; charset=utf-8"
                       },
                       {
                         :http_equiv => "Pragma",
                         :content => "no-cache"
                       }
    ], :theme_path => "home.html")

    @event_page = Page.new(:slug => "event", :title => "Event", :css_paths =>["event.css"],
                           :page_metas => [
                             {
                               :http_equiv => "Author",
                               :content => "ark"
                             }
    ], :theme_path => "even.thml")
    
    @ds_blog = D.create(:key => "blog", :name => "Blog", :ds_elements => [
                     {
                       :key => "title",
                       :name => "Title"
                     },
                     {
                       :key => "description",
                       :name => "Description"
                     }
		])
		
		@ds_dummy = D.create(:key => "ds0",
                     		:name => "dsname0",
                     		:ds_elements => [
                     			{
                     				:key => "field0",
                     				:name => "field0"	
                     			},
                     			{
                     				:key => "field1",
                     				:name => "field1"
                     			}
                     		])

    @page_with_ds = Page.create(:slug => "home_again", :title => "Home Again", :js_paths => ["accordion.js", "event/cool.js"],
                     :page_metas => [
                       {
                         :http_equiv => "Content-Type",
                         :content => "text/html; charset=utf-8"
                       },
                       {
                         :http_equiv => "Pragma",
                         :content => "no-cache"
                       }
                     ],
                     :theme_path => "home_again.html")
    @page_with_ds.ds = [@ds_dummy, @ds_blog]
    @page_with_ds.save

  end

  teardown do
    Page.all.each do |page|
      page.destroy
    end
    D.all.each do	|d|
    	d.destroy
    end
  end
  
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:pages)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create page" do
    assert_difference('Page.count') do
      post :create, :page => @event_page.attributes
    end

    assert_redirected_to page_path(assigns(:page))
  end

  test "should show page" do
    get :show, :id => @page.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @page.to_param
    assert_response :success
  end

  test "should update page title" do
    put :update, :id => @page.to_param, :page => {:title => "Home2"}
    assert_redirected_to page_path(assigns(:page))
    assert_equal assigns(:page).title, "Home2"
  end
  
  test "should update page datasource when there was no ds for a page" do 
  	put :update, :id => @page.to_param, :ds => ["#{@ds_blog.id}"]
  	assert_redirected_to page_path(assigns(:page))
  	assert_equal assigns(:page).ds.size, 1 
  end
  
  test "should update page datasource when where were ds for a page" do
  	assert_equal @page_with_ds.ds.size, 2
  	#assert_equal @page_with_ds.ds.first.id, @ds_dummy.id
  	put :update, :id => @page_with_ds.to_param, :ds => ["","#{@ds_blog.id}"]
  	assert_redirected_to page_path(assigns(:page))
  	assert_equal assigns(:page).ds.size, 1
  	assert_equal assigns(:page).ds.first.id, @ds_blog.id
  	@page_with_ds.reload
  	assert_equal @page_with_ds.ds.size, 1
  end

  test "should destroy page" do
    assert_difference('Page.count', -1) do
      delete :destroy, :id => @page.to_param
    end

    assert_redirected_to pages_path
  end
end
