# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)
page = Page.create(:slug => "home", :title => "Home", :theme_path => "page_default.html",
                   :js_paths => ["accordion", "event/cool"],
                   :css_paths => ["home"],
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
ds_blog.get_klass.create(:title => "Noah's ARK", :description => "Very first blog")

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
ds_event.get_klass.create(:name => "Open Source Camp", :when => "20110101")

page.ds = [ds_blog, ds_event]
page.save
