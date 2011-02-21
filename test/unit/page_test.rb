require 'test_helper'

class PageTest < ActiveSupport::TestCase

  teardown do
    D.all.each do |d|
      d.destroy
    end

    Page.all.each do |page|
      page.destroy
    end
  end
  
  test "create a normal page" do
    page = Page.new(:slug => "home", :title => "Home", :theme_path=> "home.liquid",
    :js_paths => ["accordion.js", "event/cool.js"],
    :page_metas => [
      {
        :http_equiv => "Content-Type",
        :content => "text/html; charset=utf-8"
      },
      {
        :http_equiv => "Pragma",
        :content => "no-cache"
      }
    ])
    assert page.valid?, page.errors.full_messages.map { |msg| msg + ".\n" }.join
    page.save
  
    page_ret = Page.find(:all).first
    assert_equal "Home", page_ret.title
    assert_equal "accordion.js", page_ret.js_paths.first
    assert_equal "event/cool.js", page_ret.js_paths.second
    assert_equal "text/html; charset=utf-8", page_ret.page_metas.first.content
    assert_equal "Pragma", page_ret.page_metas.second.http_equiv
    assert_equal "home.liquid", page_ret.theme_path
  end
  
  test "create an abnormal page, without slug" do
    page = Page.new(:title => "About")
    assert page.invalid?, page.errors.full_messages.map { |msg| msg + ".\n" }.join
    assert page.errors[:slug].any?, "should have error message about the missing slug"
  end
  
  test "create an abnormal page, with duplicated slug" do
    page = Page.new(:slug => "home", :title => "Home")
    assert page.valid?, page.errors.full_messages.map { |msg| msg + ".\n" }.join
    page.save
    page2 = Page.new(:slug => "home", :title => "Home2")
    assert page2.invalid?
  end

  test "create a page with two data sources" do
    ds_blog = D.create(:key => "blog", :name => "Blog", :ds_elements => [
      {
        :key => "title",
        :name => "Title"
      },
      {
        :key => "description",
        :name => "Description"
      }
    ])
    assert ds_blog.valid?, ds_blog.errors.full_messages.map { |msg| msg + ".\n" }.join

    ds_event = D.create(:key => "event", :name => "Event", :ds_elements => [
      {
        :key => "name",
        :name => "Name"
      },
      {
        :key => "when",
        :name => "When",
        :type => "Date"
      }
    ])
    assert ds_event.valid?, ds_event.errors.full_messages.map { |msg| msg + ".\n" }.join

    assert_equal D.all.size, 2
    
    r_page_blog = RPageD.new(:query_hash => {:limit => "2",})
    r_page_blog.d = ds_blog

    r_page_event = RPageD.new(:query_hash =>{:ascending => "when", :descending => "name", :excludes => "name = Event4"})
    r_page_event.d = ds_event

    page = Page.new(:slug => "home2", :title => "Home2")
    assert page.valid?, page.errors.full_messages.map { |msg| msg + ".\n" }.join
    page.r_page_ds = [r_page_blog, r_page_event]

    assert page.valid?, page.errors.full_messages.map { |msg| msg + ".\n" }.join
    page.save

    page_ret = Page.find(:all).first
    assert_equal page_ret.slug, "home2"
    assert_equal page_ret.r_page_ds.size, 2
    assert_equal page_ret.r_page_ds.first.d, ds_blog
    assert_equal page_ret.r_page_ds.last.d, ds_event

    # create fixtures
    ds_blog.get_klass.create(:title => "Blog1", :description => "Description1")
    ds_blog.get_klass.create(:title => "Blog2", :description => "Description2")
    ds_blog.get_klass.create(:title => "Blog3", :description => "Description3")

    ds_event.get_klass.create(:name => "Event2", :when => "2011-02-15")
    ds_event.get_klass.create(:name => "Event1", :when => "2011-02-14")
    ds_event.get_klass.create(:name => "Event3", :when => "2011-02-14")
    ds_event.get_klass.create(:name => "Event4", :when => "2011-02-14")

    blogs = page_ret.r_page_ds.first.default_query
    assert_equal blogs.size, 2

    events = page_ret.r_page_ds.last.default_query
    assert_equal events.first.name, "Event3"
    assert_equal events.size, 3
    
    # delet the ds should also delete the related ref
    assert_equal page_ret.r_page_ds.size, 2
    ds_blog.destroy
    page_ret.reload
    assert_equal page_ret.r_page_ds.size, 1
  end

end
