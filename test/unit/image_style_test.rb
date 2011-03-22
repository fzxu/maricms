require 'test_helper'

class ImageStyleTest < ActiveSupport::TestCase
  
  setup do
    ImageStyle.destroy_all  
  end
  
  # Replace this with your real tests.
  test "test create only parent image style" do
    is = ImageStyle.new(:key => "slider", :name => "For Slide Show on Home page", :width => 800, :height => 600, :format => "jpg", :crop => true)
    assert is.valid?
    is.save
    assert_equal ImageStyle.all.count,1
  end
  
  test "test create the parent and child at the same time" do
    is = ImageStyle.new(:key => "slider", :name => "For Slide Show on Home page", :width => 800, :height => 600, :format => "jpg", :crop => true,
    :child_image_styles => [
      {:key => "icon", :name => "Small icon use", :width => 80, :height => 80, :format => "jpg", :crop => true}
    ])
    assert is.valid?
    is.save
    is.reload
    assert_equal is.child_image_styles.count, 1
  end
  
  test "test create image style with versions" do
    is = ImageStyle.new(:key => "slider", :name => "For Slide Show on Home page", :width => 800, :height => 600, :format => "jpg", :crop => false)
    icon = ImageStyle.new(:key => "icon", :name => "Small icon use", :width => 80, :height => 80, :format => "jpg", :crop => true)
    enlarge = ImageStyle.new(:key => "enlarge", :name => "Large", :width => 1920, :height => 1080, :format => "jpg", :crop => false)
    is.child_image_styles << icon
    is.child_image_styles << enlarge
    assert is.valid?
    is.save
    assert_equal ImageStyle.all.count, 1
    is.reload
    
    # check master version
    assert_equal is.key, "slider"
    assert_equal is.name, "For Slide Show on Home page"
    assert_equal is.width, 800
    assert_equal is.height, 600
    assert_equal is.format, "jpg"
    assert_equal is.crop, false
    
    assert_equal is.child_image_styles.count, 2
    # check icon version
    assert_equal is.child_image_styles.first.key, "icon"
    assert_equal is.child_image_styles.first.name, "Small icon use"
    assert_equal is.child_image_styles.first.width, 80
    assert_equal is.child_image_styles.first.height, 80
    assert_equal is.child_image_styles.first.format, "jpg"
    assert_equal is.child_image_styles.first.crop, true

    # check enlarge version
    assert_equal is.child_image_styles.last.key, "enlarge"
    assert_equal is.child_image_styles.last.name, "Large"
    assert_equal is.child_image_styles.last.width, 1920
    assert_equal is.child_image_styles.last.height, 1080
    assert_equal is.child_image_styles.last.format, "jpg"
    assert_equal is.child_image_styles.last.crop, false
  end
  
  test "test generate default uploader class" do
    default = ImageStyle.new(:key => "default", :name => "Default", :width => 1920, :height => 1080, :format => "jpg", :crop => false, :quality => 100)
    uploader = default.gen_uploader_klass.new
    assert_equal uploader.class.name, "EMgDefaultUploader"
    assert uploader.respond_to?("default_url")
  end
end
