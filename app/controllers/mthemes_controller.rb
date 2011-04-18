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

class MthemesController < ApplicationController
  before_filter :get_setting
  before_filter :authenticate_user!
  
  def create
    theme_name = params[:id]
    theme_path = File.join(Rails.root, "themes", theme_name)
    
    if File.exist?(theme_path)
      FileUtils.remove_dir(theme_path)
    end
    
    repo_path = File.join(@setting.repo_path, @setting.id.to_s, theme_name)
    
    if File.exist?(repo_path)
      FileUtils.remove_dir(repo_path)
    end
    FileUtils.mkdir_p(File.join(@setting.repo_path, @setting.id.to_s))

    notice = `svnadmin create #{repo_path}`
    notice += `chown -R #{@setting.repo_user}:#{@setting.repo_group} #{repo_path}`
    notice += `svn co file://#{repo_path} #{File.join(Rails.root, "themes", theme_name)}`

    # generate the default theme
    notice += `cd #{Rails.root}; #{gem_bin_path("rails")} g theme_for_mg:theme #{theme_name} --ruby=#{ruby_bin_path("ruby")}`

    # commit in the init version
    notice += `cd #{theme_path}; svn add #{theme_path}/*`
    notice += `cd #{theme_path}; svn commit #{theme_path} -m "init"`

    # clear the cache for sure
    notice += `cd #{Rails.root}; #{gem_bin_path("rake")} tmp:cache:clear`
    
    respond_to do |format|
      format.html { redirect_to '/manage/setting', :notice => notice[0..200]}
      format.xml { head :ok}
    end
  end

  def sync
    theme_name = params[:id]

    notice = `svn update #{File.join(Rails.root, "themes", theme_name)}`
    
    notice += `cd #{File.join(Rails.root, "themes", theme_name)} ; #{gem_bin_path("rake")} themes:update_cache`

    notice += `cd #{Rails.root}; #{gem_bin_path("rake")} tmp:cache:clear`
    
    respond_to do |format|
      format.html { redirect_to '/manage/setting', :notice => notice[0..200]}
      format.xml { head :ok}
    end

  end
  
  private
  
  def ruby_bin_path(cmd)
    File.join(@setting.ruby_bin_path, cmd)
  end
  
  def gem_bin_path(cmd)
    File.join(@setting.gem_bin_path, cmd)
  end
end
