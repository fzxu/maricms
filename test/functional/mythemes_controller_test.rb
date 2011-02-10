require 'test_helper'

class MythemesControllerTest < ActionController::TestCase
  setup do
    @mytheme = mythemes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:mythemes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create mytheme" do
    assert_difference('Mytheme.count') do
      post :create, :mytheme => @mytheme.attributes
    end

    assert_redirected_to mytheme_path(assigns(:mytheme))
  end

  test "should show mytheme" do
    get :show, :id => @mytheme.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @mytheme.to_param
    assert_response :success
  end

  test "should update mytheme" do
    put :update, :id => @mytheme.to_param, :mytheme => @mytheme.attributes
    assert_redirected_to mytheme_path(assigns(:mytheme))
  end

  test "should destroy mytheme" do
    assert_difference('Mytheme.count', -1) do
      delete :destroy, :id => @mytheme.to_param
    end

    assert_redirected_to mythemes_path
  end
end
