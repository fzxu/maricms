require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  setup do
    @page = Page.new(:slug => "home", :title => "Home", :js_paths => ["accordion.js", "event/cool.js"],
                     :page_metas => [
                       {
                         :http_equiv => "Content-Type",
                         :content => "text/html; charset=utf-8"
                       },
                       {
                         :http_equiv => "Pragma",
                         :content => "no-cache"
                       }
    ])
    @page.save

    @event_page = Page.new(:slug => "event", :title => "Event", :css_paths =>["event.css"],
                           :page_metas => [
                             {
                               :http_equiv => "Author",
                               :content => "ark"
                             }
    ])
  end

  teardown do
    Page.all.each do |page|
      page.destroy
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

  test "should update page" do
    put :update, :id => @page.to_param, :page => @page.attributes
    assert_redirected_to page_path(assigns(:page))
  end

  test "should destroy page" do
    assert_difference('Page.count', -1) do
      delete :destroy, :id => @page.to_param
    end

    assert_redirected_to pages_path
  end
end
