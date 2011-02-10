require 'test_helper'

class EditorAttachmentsControllerTest < ActionController::TestCase
  setup do
    @editor_attachment = editor_attachments(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:editor_attachments)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create editor_attachment" do
    assert_difference('EditorAttachment.count') do
      post :create, :editor_attachment => @editor_attachment.attributes
    end

    assert_redirected_to editor_attachment_path(assigns(:editor_attachment))
  end

  test "should show editor_attachment" do
    get :show, :id => @editor_attachment.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @editor_attachment.to_param
    assert_response :success
  end

  test "should update editor_attachment" do
    put :update, :id => @editor_attachment.to_param, :editor_attachment => @editor_attachment.attributes
    assert_redirected_to editor_attachment_path(assigns(:editor_attachment))
  end

  test "should destroy editor_attachment" do
    assert_difference('EditorAttachment.count', -1) do
      delete :destroy, :id => @editor_attachment.to_param
    end

    assert_redirected_to editor_attachments_path
  end
end
