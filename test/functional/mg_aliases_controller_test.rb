require 'test_helper'

class MgAliasesControllerTest < ActionController::TestCase
  setup do
    @mg_alias = mg_aliases(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:mg_aliases)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create mg_alias" do
    assert_difference('MgAlias.count') do
      post :create, :mg_alias => @mg_alias.attributes
    end

    assert_redirected_to mg_alias_path(assigns(:mg_alias))
  end

  test "should show mg_alias" do
    get :show, :id => @mg_alias.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @mg_alias.to_param
    assert_response :success
  end

  test "should update mg_alias" do
    put :update, :id => @mg_alias.to_param, :mg_alias => @mg_alias.attributes
    assert_redirected_to mg_alias_path(assigns(:mg_alias))
  end

  test "should destroy mg_alias" do
    assert_difference('MgAlias.count', -1) do
      delete :destroy, :id => @mg_alias.to_param
    end

    assert_redirected_to mg_aliases_path
  end
end
