class DsStandardsController < ApplicationController
  before_filter :get_setting
  def index
    @d = D.find(params[:d])
    #@records = @d.get_klass.all.desc(:position).paginate(:page => params[:page], :per_page => @setting.per_page || 5)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tabs }
    end
  end

  def datatable
    @d = D.find(params[:d])
    @records = current_records(params)
    @total_records = total_records(params)
    
    respond_to do |format|
      format.js {render :layout => false}
    end
  end

  def edit
    @d = D.find(params[:d])
    @record = @d.get_klass.find(params[:id])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @record }
    end
  end

  def update
    @d = D.find(params[:d])
    @record = @d.get_klass.find(params[:id])

    respond_to do |format|
      if @record.update_attributes(params[:record])
        expire_action_cache(@record)
        format.html { redirect_to(ds_standards_path(:d => @d.id)) }
        format.xml  { head :ok }
      else
        render_html(@d, format)
        format.xml  { render :xml => @record.errors, :status => :unprocessable_entity }
      end
    end
  end

  def new
    @d = D.find(params[:d])
    @record = @d.get_klass.new

    respond_to do |format|
      format.html
      format.xml  { render :xml => @record }
    end
  end

  def create
    @d = D.find(params[:d])
    @record = @d.get_klass.new(params[:record])

    respond_to do |format|
      if @record.save
        expire_action_cache(@record)
        format.html { redirect_to(ds_standards_path(:d => @d.id))}
        format.xml { head :ok}
      else
        render_html(@d, format)
        format.xml { render :xml => @record.erros, :status => :unprocessable_entity}
      end
    end
  end

  def destroy
    @d = D.find(params[:d])
    @record = @d.get_klass.find(params[:id])
    @record.destroy

    respond_to do |format|
      expire_action_cache(@record)
      format.html { redirect_to(ds_standards_path(:d => @d.id)) }
      format.xml  { head :ok }
    end
  end

  def show
    @d = D.find(params[:d])
    @record = @d.get_klass.find(params[:id])

    respond_to do |format|
      format.html
      format.xml  { render :xml => @record }
    end
  end

  def move_up
    @d = D.find(params[:d])
    @record = @d.get_klass.find(params[:id])
    @record.move_up

    respond_to do |format|
      expire_action_cache(@record)
      format.html { redirect_to(ds_standards_path(:d => @d.id)) }
      format.xml  { head :ok }
    end
  end

  def move_down
    @d = D.find(params[:d])
    @record = @d.get_klass.find(params[:id])
    @record.move_down

    respond_to do |format|
      expire_action_cache(@record)
      format.html { redirect_to(ds_standards_path(:d => @d.id)) }
      format.xml  { head :ok }
    end
  end

  private

  def current_records(params={})
    current_page = (params[:iDisplayStart].to_i/params[:iDisplayLength].to_i rescue 0)+1
    
    if params[:sSearch] && !params[:sSearch].blank? 
      result = @d.get_klass.any_of(conditions)
    else
      result = @d.get_klass.all
    end
    @total_disp_records_size = result.size

    result.desc(:position).paginate :page => current_page,
    #:include => [:user],
    #:order => "#{datatable_columns(params[:iSortCol_0])} #{params[:sSortDir_0] || "DESC"}",
    :per_page => params[:iDisplayLength]
  end

  def total_records(params={})
    @d.get_klass.all.size# :include => [:user], :conditions => conditions
  end

  # def datatable_columns(column_id)
  #   case column_id.to_i
  #   when 1
  #     return "objects.description"
  #   when 2
  #     return "objects.created_at"
  #   else
  #   return "users.name"
  #   end
  # end

  def conditions
    cond = []
    sSearch = params[:sSearch]
    @d.ds_elements.each do |ds_element|
      if ds_element.ftype == "String" || ds_element.ftype == "Text"
        cond << {"#{ds_element.key}".to_sym => /#{sSearch}/}
      elsif ds_element.ftype == "Integer" && sSearch.to_i.to_s == sSearch
        cond << {"#{ds_element.key}".to_sym => sSearch.to_i}
      end
    end
    return cond
  end
end
