require 'test_helper'

class ImageStylesControllerTest < ActionController::TestCase
  setup do
    @image_style = image_styles(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:image_styles)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create image_style" do
    assert_difference('ImageStyle.count') do
      post :create, :image_style => @image_style.attributes
    end

    assert_redirected_to image_style_path(assigns(:image_style))
  end

  test "should show image_style" do
    get :show, :id => @image_style.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @image_style.to_param
    assert_response :success
  end

  test "should update image_style" do
    put :update, :id => @image_style.to_param, :image_style => @image_style.attributes
    assert_redirected_to image_style_path(assigns(:image_style))
  end

  test "should destroy image_style" do
    assert_difference('ImageStyle.count', -1) do
      delete :destroy, :id => @image_style.to_param
    end

    assert_redirected_to image_styles_path
  end
end
