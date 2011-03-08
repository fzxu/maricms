class SettingController < ApplicationController
  
  def index
    @d = D.where(:ds_type => "Standard").first
    
    if @d
      redirect_to manage_d_path(@d)
    else
      redirect_to ds_path
    end
  end
  
  def setting
    @setting = Setting.first
    unless @setting
      @setting = Setting.create(APP_CONFIG)
      @setting.reload
    end
  end

  def update
    @setting = Setting.first

    respond_to do |format|
      if @setting.update_attributes(params[:setting])
        # regenerate all the Data source classes in mem
        D.all.each do |d|
          d.gen_klass
        end
        
        format.html { redirect_to :action => "setting" }
        format.xml  { head :ok }
      else
        format.html { redirect_to :action => "setting" }
        format.xml  { render :xml => @setting.errors, :status => :unprocessable_entity }
      end
    end
  end

  def reset
    @setting = Setting.first || Setting.create

    respond_to do |format|
      if @setting.update_attributes(APP_CONFIG)
      	format.html { redirect_to :action => "setting" }
      	format.xml { head :ok}
      else
      	format.html { redirect_to :action => "setting" }
      	format.xml  { render :xml => @setting.errors, :status => :unprocessable_entity }
      end
    end
  end
end
