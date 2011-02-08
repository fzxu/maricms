require 'test_helper'

class DsControllerTest < ActionController::TestCase
  setup do
    @d_blog = D.new(:key => "blog", :name => "Blog", :ds_elements => [
                      {
                        :key => "title",
                        :name => "Title"
                      },
                      {
                        :key => "number",
                        :name => "Number",
                        :type => "Integer"
                      }
    ])
    @d_blog.save

    @d_event = D.new(:key => "event", :name => "Event", :ds_elements => [
                       {
                         :key => "name",
                         :name => "Name"
                       },
                       {
                         :key => "when",
                         :name => "When",
                         :type => "Date"
                       }
    ])
  end

  teardown do
    D.all.each do |d|
      d.destroy
    end
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:ds)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create d" do
    assert_difference('D.count', 1) do
      post :create, :d => @d_event.attributes
    end

    assert_redirected_to d_path(assigns(:d))
  end

  test "should show d" do
    get :show, :id => @d_blog.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @d_blog.to_param
    assert_response :success
  end

  # test "should update d" do
  #   put :update, :id => @d_blog.to_param, :d => @d_blog.attributes
  #   assert_redirected_to edit_d_path(assigns(:d))
  # end

  test "should update d with params" do #change the update behavior to adopt the ui side
    put :update, :id => @d_blog.to_param, :d => {
    	"ds_elements"=>{"4d5030558dd76d2548000009"=>{"key"=>"name", "name"=>"Name", "type"=>"String"}}}
    assert_redirected_to edit_d_path(assigns(:d))
    d = assigns(:d).reload
    assert_equal d.ds_elements.size, 1
  end

  test "should destroy d" do
    assert_difference('D.count', -1) do
      delete :destroy, :id => @d_blog.to_param
    end

    assert_redirected_to ds_path
  end
  
  test "should add new ds element" do
  	assert_equal @d_blog.ds_elements.size, 2
  	post :create_ds_element, :id => @d_blog.to_param, :ds_element => {:key => 'key1', :name => 'name1', :type => 'Integer'}
  	assert_redirected_to edit_d_path(assigns(:d))

    d = assigns(:d).reload
    assert_equal d.ds_elements.size, 3  	
  end
end
