require 'test_helper'

class DsTreesControllerTest < ActionController::TestCase
  setup do
    @ds_tree = ds_trees(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:ds_trees)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create ds_tree" do
    assert_difference('DsTree.count') do
      post :create, :ds_tree => @ds_tree.attributes
    end

    assert_redirected_to ds_tree_path(assigns(:ds_tree))
  end

  test "should show ds_tree" do
    get :show, :id => @ds_tree.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @ds_tree.to_param
    assert_response :success
  end

  test "should update ds_tree" do
    put :update, :id => @ds_tree.to_param, :ds_tree => @ds_tree.attributes
    assert_redirected_to ds_tree_path(assigns(:ds_tree))
  end

  test "should destroy ds_tree" do
    assert_difference('DsTree.count', -1) do
      delete :destroy, :id => @ds_tree.to_param
    end

    assert_redirected_to ds_trees_path
  end
end
