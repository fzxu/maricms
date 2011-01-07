require 'test_helper'

class PageTest < ActiveSupport::TestCase

  def setup
    Page.find(:all).each do |page|
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
    ds_blog = D.new(:key => "blog", :name => "Blog", :ds_elements => [
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

    ds_event = D.new(:key => "event", :name => "Event", :ds_elements => [
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

    page = Page.new(:slug => "home2", :title => "Home2")
    assert page.valid?, page.errors.full_messages.map { |msg| msg + ".\n" }.join
    page.ds = [ds_blog, ds_event]

    assert page.valid?, page.errors.full_messages.map { |msg| msg + ".\n" }.join
    page.save

    page_ret = Page.find(:all).first
    assert_equal page_ret.slug, "home2"
    assert_equal page_ret.ds.first, ds_blog
    assert_equal page_ret.ds.second, ds_event
  end
end