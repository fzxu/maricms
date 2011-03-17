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
    @records = current_records(@d, params)
    @total_records = total_records(@d)

    respond_to do |format|
      format.js {render :layout => false}
    end
  end

  def edit
    @d = D.find(params[:d])
    @record = @d.get_klass.find(params[:id])
    mg_alias = MgAlias.where(:d_id => @d.id).and(:record_id => @record.id)
    if mg_alias.count == 1
      @mg_alias = mg_alias.first
    end
    
    respond_to do |format|
      format.html
      format.xml  { render :xml => @record }
    end
  end

  def update
    p_mg_alias = params.delete(:mg_alias)
    
    @d = D.find(params[:d])
    @record = @d.get_klass.find(params[:id])

    respond_to do |format|
      if @record.update_attributes(params[:record])
        mg_alias = MgAlias.where(:d_id => @d.id).and(:record_id => @record.id)
        if mg_alias.count == 1
          @mg_alias = mg_alias.first
        else
          @mg_alias = MgAlias.new(:d_id => @d.id, :record_id => @record.id)
        end
          
        @mg_alias.mg_alias = p_mg_alias
        @mg_alias.save

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
    mg_alias = params.delete(:mg_alias)
    
    @d = D.find(params[:d])
    @record = @d.get_klass.new(params[:record])

    respond_to do |format|
      if @record.save
        if mg_alias
          MgAlias.create(:mg_alias => mg_alias, :d_id => @d.id, :record_id => @record.id)
        end
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
  
  def current_records(d, params={})
    current_page = (params[:iDisplayStart].to_i/params[:iDisplayLength].to_i rescue 0)+1

    if params[:sSearch].blank?
      result = d.get_klass.all
    else
      result = d.get_klass.any_of(conditions(d, params))
    end
    @total_disp_records_size = result.size

    result.desc(:position).paginate :page => current_page,
    #:include => [:user],
    #:order => "#{datatable_columns(params[:iSortCol_0])} #{params[:sSortDir_0] || "DESC"}",
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
