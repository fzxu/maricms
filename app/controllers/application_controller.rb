class ApplicationController < ActionController::Base
  protect_from_forgery
  def get_theme
    @setting.current_theme
  end

  def get_setting
    @setting = Setting.first

    unless @setting
      redirect_to "/manage/setting"
    end
  end

  # due to sweeper in mongoid does not work
  def expire_action_cache(record)
    Page.all.each do |p|
      if p.r_page_ds
        p.r_page_ds.each do |r_page_d|
          if record.is_a?(r_page_d.d.get_klass)
            # remove the binding pages cache
            expire_fragment(/pages\S+#{p.slug}/)
            expire_fragment(/pages\S+#{p.id}/)

            # remove related tab cache
            D.where(:ds_type => "Tab").each do |d|
              d.get_klass.where(:page_id => p.id).each do |tab|
                expire_fragment(/tabs\S+#{tab.slug}/)
                expire_fragment(/tabs\S+#{tab.id}/)
              end
            end
          end
        end
      end
    end
  end

  def expire_cache_for_page(record)
    expire_fragment(/pages\S+#{record.slug}/)
    expire_fragment(/pages\S+#{record.id}/)
    # remove related tab cache
    D.where(:ds_type => "Tab").each do |d|
      d.get_klass.where(:page_id => record.id).each do |tab|
      #expire_action :controller => :tabs, :action => :show, :cache_path => Proc.new { |c| "tab_#{tab.slug}*" }
        expire_fragment(/tabs\S+#{tab.slug}/)
        expire_fragment(/tabs\S+#{tab.id}/)
      end
    end
  end
end
