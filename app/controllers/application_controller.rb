class ApplicationController < ActionController::Base
  protect_from_forgery
  
 
  def get_theme
    @setting.current_theme
  end
  
  def get_setting
  	@setting = Setting.first
  	
  	unless @setting
  		redirect_to "/setting"
  	end
  end
  
  def get_all_ds
    @ds = D.all
  end
end
