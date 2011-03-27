require 'test_helper'

class DsSinglesControllerTest < ActionController::TestCase
  setup do
    @ds_single = ds_singles(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:ds_singles)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create ds_single" do
    assert_difference('DsSingle.count') do
      post :create, :ds_single => @ds_single.attributes
    end

    assert_redirected_to ds_single_path(assigns(:ds_single))
  end

  test "should show ds_single" do
    get :show, :id => @ds_single.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @ds_single.to_param
    assert_response :success
  end

  test "should update ds_single" do
    put :update, :id => @ds_single.to_param, :ds_single => @ds_single.attributes
    assert_redirected_to ds_single_path(assigns(:ds_single))
  end

  test "should destroy ds_single" do
    assert_difference('DsSingle.count', -1) do
      delete :destroy, :id => @ds_single.to_param
    end

    assert_redirected_to ds_singles_path
  end
end
