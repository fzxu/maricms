class MthemesController < ApplicationController
  before_filter :get_setting
  
  def create
    theme_name = params[:id]
    if File.exist?(File.join(Rails.root, "themes", theme_name))
      FileUtils.remove_dir(File.join(Rails.root, "themes", theme_name))
    end
    
    repo_path = File.join(@setting.repo_root, @setting.id.to_s, theme_name)
    ruby_bin_path = File.join(@setting.ruby_home, "bin")
    
    if File.exist?(repo_path)
      FileUtils.remove_dir(repo_path)
    end

    notice = `svnadmin create #{repo_path}`
    notice += `chown -R svn #{repo_path}`
    notice += `chgrp -R svn #{repo_path}`
    notice += `svn co svn+ssh://svn@#{@setting.host_name}#{repo_path} #{File.join(Rails.root, "themes", theme_name)}`

    notice += `cd #{Rails.root}; #{ruby_bin_path}/rails g theme_for_mg:theme #{theme_name} --ruby=#{ruby_bin_path}/ruby`

    notice += `svn add #{File.join(Rails.root, "themes", theme_name)}/*`
    notice += `svn commit #{File.join(Rails.root, "themes", theme_name)} -m "init"`

    respond_to do |format|
      format.html { redirect_to '/manage/setting', :notice => notice}
      format.xml { head :ok}
    end
  end

  def sync
    theme_name = params[:id]

    notice = `svn update #{File.join(Rails.root, "themes", theme_name)}`
    
    notice += `cd #{File.join(Rails.root, "themes", theme_name)} ; #{ruby_bin_path}/rake themes:update_cache`

    respond_to do |format|
      format.html { redirect_to '/manage/setting', :notice => notice}
      format.xml { head :ok}
    end

  end
end
