class SettingController < ApplicationController
  def index
    @setting = Setting.first || Setting.create
  end

  def update
    @setting = Setting.first

    respond_to do |format|
      if @setting.update_attributes(params[:setting])
        format.html { redirect_to :action => "index" }
        format.xml  { head :ok }
      else
        format.html { redirect_to :action => "index" }
        format.xml  { render :xml => @setting.errors, :status => :unprocessable_entity }
      end
    end
  end

  def reset
    @setting = Setting.first || Setting.create

    respond_to do |format|
      if @setting.update_attributes({"application_title"=>"TianTing", "current_theme"=>"default",
      "image_style"=>{:original=>["1920x1680>", :jpg], :small=>["100x100#", :jpg], :medium=>["250x250", :jpg], :large=>["500x500>", :jpg]},
       "date_format"=>"%Y-%m-%d", "time_format"=>"%H:%M", "attachment_max_size"=>"", "host_name"=>"localhost"})
      	format.html { redirect_to :action => "index" }
      	format.xml { head :ok}
      else
      	format.html { redirect_to :action => "index" }
      	format.xml  { render :xml => @setting.errors, :status => :unprocessable_entity }
      end
    end
  end
end
