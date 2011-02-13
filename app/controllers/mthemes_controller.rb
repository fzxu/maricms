class MthemesController < ApplicationController
  before_filter :get_setting
  
  def create
    theme_name = params[:theme_name]
    if Dir.exist?(File.join(Rails.root, "themes", theme_name))
      FileUtils.remove_dir(File.join(Rails.root, "themes", theme_name))
    end
    notice = `rails g theme_for_tt:theme #{theme_name}`
    `svnadmin create /home/svn/#{theme_name}`
    `chown svn /home/svn/#{theme_name}`
    `chgrp www-data /home/svn/#{theme_name}`
    `svn co svn+ssh://#{@setting.host_name}/home/svn/#{theme_name}`
    
    respond_to do |format|
      format.html { redirect_to '/setting', :notice => notice}
      format.xml { head :ok}
    end
  end
end
