class ApplicationController < ActionController::Base
  include HttpAcceptLanguage
  
  protect_from_forgery
  before_filter :set_locale
  def set_locale
    # if params[:locale] is nil then I18n.default_locale will be used
    logger.debug "*MG Accept-Language: #{request.env['HTTP_ACCEPT_LANGUAGE']}"
    I18n.locale = params[:locale] || preferred_language_from(AVAILABLE_LANGUAGES)
    logger.debug "*MG Locale set to '#{I18n.locale}'"
  end

  def default_url_options(options={})
    logger.debug "*MG default_url_options is passed options: #{options.inspect}\n"
    if params[:locale]
      { :locale => I18n.locale }
    else
      {}
    end
  end

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
            expire_alias_for_page(p)
          end
        end
      end
    end
  end

  def expire_cache_for_page(page)
    #expire_fragment(/pages\S+#{page.slug}/)
    expire_fragment(/pages\S+#{page.id}/)
    # remove related alias cache
    expire_alias_for_page(page)
  end

  def handle_mobile
    request.format = :mobile if mobile_user_agent?
  end

  def mobile_user_agent?
    agent = request.headers["HTTP_USER_AGENT"].downcase
    unless @mobile_user_agent
      MOBILE_BROWSERS.each do |m|
        @mobile_user_agent = agent.match(m) && !(agent =~ /ipad/)
        break if @mobile_user_agent
      end
    end
    @mobile_user_agent
  end

  private

  def expire_alias_for_page(page)
    MgUrl.where(:page_id => page.id).each do |a|
      expire_fragment(/\S+#{a.path}/)
      expire_fragment(/\S+\/index/)
      expire_fragment(/\S+\/.mobile/)
    end
  end
end
