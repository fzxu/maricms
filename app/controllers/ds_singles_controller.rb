class DsSinglesController < ApplicationController
  before_filter :get_setting
  before_filter :authenticate_user!
  
  # GET /ds_singles
  # GET /ds_singles.xml
  def index
    @d = D.find(params[:d])
    @record = @d.get_klass.first || @d.get_klass.new

    respond_to do |format|
      format.html { render :layout => "ds_view_#{@d.ds_view_type.downcase}"}
      format.xml  { render :xml => @record }
    end
  end

  # POST /ds_singles
  # POST /ds_singles.xml
  def create
    mg_url = params[:record].delete(:mg_url)
  
    @d = D.find(params[:d])
    @record = @d.get_klass.first
    unless @record
      @record = @d.get_klass.new(params[:record])
    end

    unless mg_url[:path].blank?
      @record.mg_url = MgUrl.new(mg_url) unless @record.mg_url
    end
    
    respond_to do |format|
      if @record.save && @record.update_attributes(params[:record]) && (@record.mg_url.update_attributes(mg_url) if @record.mg_url)
        format.html { redirect_to(ds_singles_path(:d => @d.id), :notice => 'Ds single was successfully created.') }
        format.xml  { render :xml => @ds_single, :status => :created, :location => @ds_single }
      else
        format.html { render :action => "index", :layout => "ds_view_#{@d.ds_view_type.downcase}" }
        format.xml  { render :xml => @ds_single.errors, :status => :unprocessable_entity }
      end
    end
  end

end
