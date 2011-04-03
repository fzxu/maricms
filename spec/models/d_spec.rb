require "spec_helper"

describe D do

  after(:each) do
    D.destroy_all
  end

  context "all should be successful" do
    it "should create a ds named blog" do
      blog = D.create(:key => "blog", :name => "Blog", :ds_elements => [
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

      blog.should have(0).error_on(:errors)

      blog.reload.key.should eq("blog")
      blog.reload.name.should eq("Blog")
      blog.reload.ds_elements.size.should eq(2)
      blog.reload.ds_elements.first.key.should eq("title")
      blog.reload.ds_elements.first.name.should eq("Title")
      blog.reload.ds_elements.last.key.should eq("number")
      blog.reload.ds_elements.last.name.should eq("Number")
      blog.reload.ds_elements.last.ftype.should eq("Integer")
    end

    it "should create a model from ds element dynamically" do
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

      blog.reload.number.should eq(2)
    end
    
    it "should create ds successfully with the following key format" do
      blog_meta3 = D.create(:key => "blog_1", :name => "Blog")
      blog_meta3.should have(0).error_on(:errors)
      blog_meta3.get_klass.should_not be_nil
    
      blog_meta4 = D.create(:key => "blog_true", :name => "Blog")
      blog_meta4.should have(0).error_on(:errors)
      blog_meta4.get_klass.should_not be_nil
          
      blog_meta5 = D.create(:key => "blog_365_good", :name => "Blog")
      blog_meta5.should have(0).error_on(:errors)
      blog_meta5.get_klass.should_not be_nil
    end
  end

  context "all should be fail as expected" do

    it "can not create ds_element without key" do
      blog = D.new(:key => "blog", :name => "Blog", :ds_elements => [
        {
          :key => "",
          :name => "Title"
        }
      ])
      blog.should have(1).error_on(:ds_elements)
      blog.ds_elements.first.should have(2).error_on(:key)
    end

    it "is not allowed to add ds data with same field value when the field is declared as unique" do
      blog_meta = D.create(:key => "blog", :name => "Blog", :ds_elements => [
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
      blog1.should have(0).error_on(:errors)

      blog2 = klass.create(:slug => "blog1", :title => "Noah's ARK2", :number => 3)
      blog2.should have(1).error_on(:slug)

      assert_equal klass.all.size, 1

      blog3 = klass.create(:slug => "blog3", :title => "Noah's ARK2", :number => 4)
      blog3.should have(0).error_on(:errors)

      assert_equal klass.all.size, 2

      blog4 = klass.create(:slug => "blog4", :title => "Noah's ARK2", :number => 4)
      blog4.should have(1).error_on(:number)

      assert_equal klass.all.size, 2
    end

    it "is not allowed to add ds data with no given field value when the field is declared as notnull" do
      blog_meta = D.create(:key => "blog", :name => "Blog", :ds_elements => [
        { :key => "slug",
          :name => "Slug",
          :unique => true,
          :notnull=> true
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
      blog1.should have(0).error_on(:errors)
    
      blog2 = klass.create(:slug => "", :title => "Noah's ARK2", :number => 3)
      blog2.should have(1).error_on(:slug)
    
      assert_equal klass.all.size, 1
    end
    
    it "should not create those ds successfully, due to invalid key format" do
      blog_meta0 = D.create(:key => "0blog", :name => "Blog")
      blog_meta0.should have(1).error_on(:key)
    
      blog_meta1 = D.create(:key => "blog%", :name => "Blog")
      blog_meta1.should have(1).error_on(:key)
    
      blog_meta2 = D.create(:key => "blog/", :name => "Blog")
      blog_meta2.should have(1).error_on(:key)    
    end

  end
end