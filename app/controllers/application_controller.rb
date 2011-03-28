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
            #expire_fragment(/pages\S+#{p.slug}/)
            expire_fragment(/pages\S+#{p.id}/)

            # remove related alias cache
            MgUrl.where(:page_id => p.id).each do |a|
              expire_fragment(/\S+#{a.path}/)
            end
          end
        end
      end
    end
  end

  def expire_cache_for_page(page)
    #expire_fragment(/pages\S+#{page.slug}/)
    expire_fragment(/pages\S+#{page.id}/)
    # remove related alias cache
    MgUrl.where(:page_id => page.id).each do |a|
      expire_fragment(/\S+#{a.path}/)
    end
  end
end
