class MthemesController < ApplicationController
  before_filter :get_setting
  
  def create
    theme_name = params[:id]
    if File.exist?(File.join(Rails.root, "themes", theme_name))
      FileUtils.remove_dir(File.join(Rails.root, "themes", theme_name))
    end
    if File.exist?("/home/svn/default")
      FileUtils.remove_dir("/home/svn/default")
    end

    notice = `svnadmin create /home/svn/#{theme_name}`
    notice += `chown -R svn /home/svn/#{theme_name}`
    notice += `chgrp -R svn /home/svn/#{theme_name}`
    notice += `svn co svn+ssh://svn@#{@setting.host_name}/home/svn/#{theme_name} #{File.join(Rails.root, "themes", theme_name)}`

    notice += `cd #{Rails.root}; /usr/local/ruby/bin/rails g theme_for_tt:theme #{theme_name} --ruby=/usr/local/ruby/bin/ruby`

    notice += `svn add #{File.join(Rails.root, "themes", theme_name)}/*`
    notice += `svn commit #{File.join(Rails.root, "themes", theme_name)} -m "init"`

    respond_to do |format|
      format.html { redirect_to '/setting', :notice => notice}
      format.xml { head :ok}
    end
  end

  def sync
    theme_name = params[:id]

    notice = `svn update #{File.join(Rails.root, "themes", theme_name)}`
    
    notice += `cd #{File.join(Rails.root, "themes", theme_name)} ; /usr/local/ruby/bin/rake themes:update_cache`

    respond_to do |format|
      format.html { redirect_to '/setting', :notice => notice}
      format.xml { head :ok}
    end

  end
end
