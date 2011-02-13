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
    blog = D.new(:key => "blog", :name => "Blog", :ds_elements => [
      {
        :key => "title",
        :name => "Title"
      },
      {
        :key => "number",
        :name => "Number",
        :ftype => "Integer"
      }
      ])
    blog.save
    
    blog_ret = D.find(:first)
    assert_equal "Blog", blog_ret.name
    assert_equal "Title", blog_ret.ds_elements.first.name
  end
  
  test "can not create ds element without key" do
    blog = D.new(:key => "blog", :name => "Blog", :ds_elements => [
      {
        :key => "",
        :name => "Title"
      }
      ])
    assert blog.ds_elements.first.invalid?, "The ds element should not be correct as there is no key"
    assert blog.ds_elements.first.errors[:key].any?
  end
  
  test "create a model from ds element dynamically" do
    blog_meta = D.new(:key => "blog", :name => "Blog", :ds_elements => [
      {
        :key => "title",
        :name => "Title"
      },
      {
        :key => "number",
        :name => "Number",
        :ftype => "Integer"
      }
      ])
    klass = blog_meta.get_klass
    
    blog = klass.new(:title => "Noah's ARK", :number => 2)
    blog.save
    
    blog_ret = klass.where(:title => "Noah's ARK").first
    assert_equal 2, blog_ret.number
    
    # remove the test data
    klass.find(:all).each do |record|
      record.destroy
    end
  end
end
