require 'test_helper'

class DsSingleTest < ActiveSupport::TestCase
  
  teardown do
    D.find(:all).each do |d|
      d.destroy
    end
  end
  
  test "create single ds" do
    ds_single = D.create(:key => "setting", :name => "设置", :ds_type => "Single", :ds_view_type => "Developer",
    :ds_elements => [
      {
        :key => "title", 
        :name => "Title"
      }
    ])
    assert ds_single.valid?
    setting = ds_single.gen_klass.new(:title => "default")
    
    assert setting.valid?
    setting.save!
    setting.reload
    assert_equal setting.class.superclass, DsSingle
    assert_equal setting.title, "default"
    assert_equal ds_single.gen_klass.all.count, 1
  end
end
