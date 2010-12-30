require 'test_helper'

class DsControllerTest < ActionController::TestCase
  setup do
    @d = ds(:one)
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
    assert_difference('D.count') do
      post :create, :d => @d.attributes
    end

    assert_redirected_to d_path(assigns(:d))
  end

  test "should show d" do
    get :show, :id => @d.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @d.to_param
    assert_response :success
  end

  test "should update d" do
    put :update, :id => @d.to_param, :d => @d.attributes
    assert_redirected_to d_path(assigns(:d))
  end

  test "should destroy d" do
    assert_difference('D.count', -1) do
      delete :destroy, :id => @d.to_param
    end

    assert_redirected_to ds_path
  end
end
