require 'test_helper'

class DTest < ActiveSupport::TestCase
  
  def setup
    D.find(:all).each do |d|
      d.destroy
    end
  end

  def teardown
    
  end
  
  test "create a blog data source" do
    blog = D.new(:name => "Noah's ARK", :ds_elements => [
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
    blog.save
    
    blog_ret = D.find(:first)
    assert_equal "Noah's ARK", blog_ret.name
  end
  
  test "can not create ds element without key" do
    blog = D.new(:name => "Noah's ARK", :ds_elements => [
      {
        :key => "",
        :name => "Title"
      }
      ])
    assert blog.ds_elements.first.invalid?, "The ds element should not be correct as there is no key"
    assert blog.ds_elements.first.errors[:key].any?
  end
end
