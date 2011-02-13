class MthemesController < ApplicationController
  before_filter :get_setting
  
  def create
    theme_name = params[:theme_name]
    if Dir.exist?(File.join(Rails.root, "themes", theme_name))
      FileUtils.remove_dir(File.join(Rails.root, "themes", theme_name))
    end
    if Dir.exist?("/home/svn/default")
      FileUtils.remove_dir("/home/svn/default")
    end

    `svnadmin create /home/svn/#{theme_name}`
    `chown -R svn /home/svn/#{theme_name}`
    `chgrp -R www-data /home/svn/#{theme_name}`
    `svn co svn+ssh://svn@#{@setting.host_name}/home/svn/#{theme_name} #{File.join(Rails.root, "themes", theme_name)}`

    notice = `rails g theme_for_tt:theme #{theme_name}`
    
    `cd #{File.join(Rails.root, "themes", theme_name)}`
    `svn add *`
    `svn commit -m "init"`
    
    respond_to do |format|
      format.html { redirect_to '/setting', :notice => notice}
      format.xml { head :ok}
    end
  end
end
