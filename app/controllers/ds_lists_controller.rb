class DsListsController < ApplicationController
  before_filter :get_setting
  def index
    @d = D.find(params[:d])

    respond_to do |format|
      format.html {render :layout => "ds_view_#{@d.ds_view_type.downcase}" }
      format.xml  { render :xml => @tabs }
    end
  end

  def datatable
    @d = D.find(params[:d])
    @records = current_records(@d, params)
    @total_records = total_records(@d)

    respond_to do |format|
      format.js {render :layout => false}
    end
  end

  def edit
    @d = D.find(params[:d])
    @record = @d.get_klass.find(params[:id])
    
    respond_to do |format|
      format.html {render :layout => "ds_view_#{@d.ds_view_type.downcase}" }
      format.xml  { render :xml => @record }
    end
  end

  def update
    mg_url = params[:record].delete(:mg_url)
    
    @d = D.find(params[:d])
    @record = @d.get_klass.find(params[:id])

    if mg_url[:path].blank?
      if @record.mg_url
        @record.mg_url.destroy
      end
    else
      if @record.mg_url
        @record.mg_url.update_attributes(mg_url)
      else
        @record.mg_url = MgUrl.new(mg_url)
      end
    end
    
    respond_to do |format|
      if @record.update_attributes(params[:record])
        expire_action_cache(@record)
        format.html { redirect_to(ds_lists_path(:d => @d.id)) }
        format.xml  { head :ok }
      else
        format.html { render :edit, :layout => "ds_view_#{@d.ds_view_type.downcase}"}
        format.xml  { render :xml => @record.errors, :status => :unprocessable_entity }
      end
    end
  end

  def new
    @d = D.find(params[:d])
    @record = @d.get_klass.new

    respond_to do |format|
      format.html {render :layout => "ds_view_#{@d.ds_view_type.downcase}" }
      format.xml  { render :xml => @record }
    end
  end

  def create
    mg_url = params[:record].delete(:mg_url)
    
    @d = D.find(params[:d])
    @record = @d.get_klass.new(params[:record])

    # update the mg url
    unless mg_url[:path].blank?
      @record.mg_url = MgUrl.new(mg_url)
    end

    respond_to do |format|
      if @record.save
        expire_action_cache(@record)
        format.html { redirect_to(ds_lists_path(:d => @d.id))}
        format.xml { head :ok}
      else
        format.html {render :new, :layout => "ds_view_#{@d.ds_view_type.downcase}"}
        format.xml { render :xml => @record.erros, :status => :unprocessable_entity}
      end
    end
  end

  def destroy
    @d = D.find(params[:d])
    @record = @d.get_klass.find(params[:id])
    @mg_url = @record.mg_url
    @record.destroy
    if @mg_url
      @mg_url.destroy
    end


    respond_to do |format|
      expire_action_cache(@record)
      format.html { redirect_to(ds_lists_path(:d => @d.id)) }
      format.xml  { head :ok }
    end
  end

  def show
    @d = D.find(params[:d])
    @record = @d.get_klass.find(params[:id])

    respond_to do |format|
      format.html {render :layout => "ds_view_#{@d.ds_view_type.downcase}" }
      format.xml  { render :xml => @record }
    end
  end

  def move_up
    @d = D.find(params[:d])
    @record = @d.get_klass.find(params[:id])
    @record.move_up

    respond_to do |format|
      expire_action_cache(@record)
      format.html { redirect_to(ds_lists_path(:d => @d.id)) }
      format.xml  { head :ok }
    end
  end

  def move_down
    @d = D.find(params[:d])
    @record = @d.get_klass.find(params[:id])
    @record.move_down

    respond_to do |format|
      expire_action_cache(@record)
      format.html { redirect_to(ds_lists_path(:d => @d.id)) }
      format.xml  { head :ok }
    end
  end

  private
  
  def current_records(d, params={})
    current_page = (params[:iDisplayStart].to_i/params[:iDisplayLength].to_i rescue 0)+1

    if params[:sSearch].blank?
      result = d.get_klass.all
    else
      result = d.get_klass.any_of(conditions(d, params))
    end
    @total_disp_records_size = result.size

    result.desc(:position).paginate :page => current_page,
    :per_page => params[:iDisplayLength]
  end
  
  def total_records(d)
    d.get_klass.all.size
  end

  def conditions(d, params={})
    cond = []
    sSearch = params[:sSearch]
    d.get_klass.fields.each do |field|
      if  field.last.type == "Integer" && sSearch.to_i.to_s == sSearch
        cond << {"#{field.last.name}".to_sym => sSearch.to_i}
      elsif
        cond << {"#{field.last.name}".to_sym => /#{sSearch}/}
      end
    end
    return cond
  end

end
