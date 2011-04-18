##
# MariCMS
# Copyright 2011 金盏信息科技(上海)有限公司 | MariGold Information Tech. Co,. Ltd.
# http://www.maricms.com

# This file is part of MariCMS, an open source content management system.

# MariGold MariCMS is free software: you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, version 3 of the License.
# 
# Under the terms of the GNU Affero General Public License you must release the
# complete source code for any application that uses any part of MariCMS
# (system header files and libraries used by the operating system are excluded).
# These terms must be included in any work that has MariCMS components.
# If you are developing and distributing open source applications under the
# GNU Affero General Public License, then you are free to use MariCMS.
# 
# If you are deploying a web site in which users interact with any portion of
# MariCMS over a network, the complete source code changes must be made
# available.  For example, include a link to the source archive directly from
# your web site.
# 
# For OEMs, ISVs, SIs and VARs who distribute MariCMS with their products,
# and do not license and distribute their source code under the GNU
# Affero General Public License, MariGold provides a flexible commercial
# license.
# 
# To anyone in doubt, we recommend the commercial license. Our commercial license
# is competitively priced and will eliminate any confusion about how
# MariCMS can be used and distributed.
# 
# MariCMS is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU Affero General Public License for more
# details.
# 
# You should have received a copy of the GNU Affero General Public License
# along with MariCMS.  If not, see <http://www.gnu.org/licenses/>.
# 
# Attribution Notice: MariCMS is an Original Work of software created
# by  金盏信息科技(上海)有限公司 | MariGold Information Tech. Co,. Ltd.
##


class ApplicationController < ActionController::Base
  include HttpAcceptLanguage
  
  protect_from_forgery
  before_filter :set_locale
  def set_locale
    # if params[:locale] is nil then I18n.default_locale will be used
    logger.debug "*MG Accept-Language: #{request.env['HTTP_ACCEPT_LANGUAGE']}"
    I18n.locale = params[:locale] || Setting.first.default_lang
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
