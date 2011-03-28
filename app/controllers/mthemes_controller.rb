class MthemesController < ApplicationController
  before_filter :get_setting
  
  def create
    theme_name = params[:id]
    theme_path = File.join(Rails.root, "themes", theme_name)
    
    if File.exist?(theme_path)
      FileUtils.remove_dir(theme_path)
    end
    
    repo_path = File.join(@setting.repo_root, @setting.id.to_s, theme_name)
    
    if File.exist?(repo_path)
      FileUtils.remove_dir(repo_path)
    end
    FileUtils.mkdir_p(File.join(@setting.repo_root, @setting.id.to_s))

    notice = `svnadmin create #{repo_path}`
    notice += `chown -R svn #{repo_path}`
    notice += `chgrp -R svn #{repo_path}`
    notice += `svn co file://#{repo_path} #{File.join(Rails.root, "themes", theme_name)}`

    notice += `cd #{Rails.root}; #{ruby_bin_path}/rails g theme_for_mg:theme #{theme_name} --ruby=#{ruby_bin_path}/ruby`

    notice += `cd #{theme_path}; svn add #{theme_path}/*`
    notice += `cd #{theme_path}; svn commit #{theme_path} -m "init"`

    respond_to do |format|
      format.html { redirect_to '/manage/setting', :notice => notice}
      format.xml { head :ok}
    end
  end

  def sync
    theme_name = params[:id]

    notice = `svn update #{File.join(Rails.root, "themes", theme_name)}`
    
    notice += `cd #{File.join(Rails.root, "themes", theme_name)} ; #{ruby_bin_path}/rake themes:update_cache`

    notice += `cd #{Rails.root}; #{ruby_bin_path}/rake tmp:cache:clear`
    
    respond_to do |format|
      format.html { redirect_to '/manage/setting', :notice => notice}
      format.xml { head :ok}
    end

  end
  
  private
  
  def ruby_bin_path
    File.join(@setting.ruby_home, "bin")
  end
end
