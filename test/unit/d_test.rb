require 'test_helper'

class DTest < ActiveSupport::TestCase
  def setup
    D.find(:all).each do |d|
      d.destroy
    end
    @setting = Setting.first || Setting.create(APP_CONFIG)
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

  test "test the ds_element unique attribute" do
    blog_meta = D.new(:key => "blog", :name => "Blog", :ds_elements => [
      { :key => "slug",
        :name => "Slug",
        :unique => true
      },
      {
        :key => "title",
        :name => "Title"
      },
      {
        :key => "number",
        :name => "Number",
        :ftype => "Integer",
        :unique => true
      }
    ])

    klass = blog_meta.gen_klass

    blog1 = klass.create(:slug => "blog1", :title => "Noah's ARK", :number => 2)
    assert blog1.valid?, blog1.errors.full_messages.map { |msg| msg + ".\n" }.join

    blog2 = klass.create(:slug => "blog1", :title => "Noah's ARK2", :number => 3)
    assert blog2.invalid?, blog2.errors.full_messages.map { |msg| msg + ".\n" }.join

    assert_equal klass.all.size, 1

    blog3 = klass.create(:slug => "blog3", :title => "Noah's ARK2", :number => 4)
    assert blog3.valid?, blog3.errors.full_messages.map { |msg| msg + ".\n" }.join
    
    assert_equal klass.all.size, 2
    
    blog4 = klass.create(:slug => "blog4", :title => "Noah's ARK2", :number => 4)
    assert blog4.invalid?, blog4.errors.full_messages.map { |msg| msg + ".\n" }.join
    
    assert_equal klass.all.size, 2
  end
end
