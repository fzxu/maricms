class SettingController < ApplicationController
      
  def index
    @setting = Setting.first || Setting.create(APP_CONFIG)
  end

  def update
    @setting = Setting.first

    respond_to do |format|
      if @setting.update_attributes(params[:setting])
        # regenerate all the Data source classes in mem
        D.all.each do |d|
          d.gen_klass
        end
        
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
      if @setting.update_attributes(APP_CONFIG)
      	format.html { redirect_to :action => "index" }
      	format.xml { head :ok}
      else
      	format.html { redirect_to :action => "index" }
      	format.xml  { render :xml => @setting.errors, :status => :unprocessable_entity }
      end
    end
  end
end
