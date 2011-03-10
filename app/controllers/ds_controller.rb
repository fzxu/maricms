class DsController < ApplicationController
  before_filter :get_setting
  
  # GET /ds
  # GET /ds.xml
  def index
    #@ds = D.all
    
    respond_to do |format|
      format.html
      format.xml  { render :xml => @ds }
    end
  end

  def datatable
    @records = current_records(params)
    @total_records = total_records()

    respond_to do |format|
      format.js {render :layout => false}
    end
  end

  # GET /ds/1
  # GET /ds/1.xml
  def show
    @d = D.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @d }
    end
  end

  # GET /ds/new
  # GET /ds/new.xml
  def new
    @d = D.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @d }
    end
  end

  # GET /ds/1/edit
  def edit
    @d = D.find(params[:id])
    @ds_element = DsElement.new
  end

  # POST /ds
  # POST /ds.xml
  def create
    @d = D.new(params[:d])

    respond_to do |format|
      if @d.save
        format.html { redirect_to(@d, :notice => 'D was successfully created.') }
        format.xml  { render :xml => @d, :status => :created, :location => @d }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @d.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /ds/1
  # PUT /ds/1.xml
  def update
    @d = D.find(params[:id])
    new_ds_elements = params[:d].delete(:ds_elements)
    unless new_ds_elements.blank?
      @d.ds_elements.destroy_all
      new_ds_elements.each do |key, value|
        @d.ds_elements << DsElement.new(value)
      end
    end

    respond_to do |format|
      if @d.update_attributes(params[:d]) && @d.save
        format.html { redirect_to(edit_d_path(@d)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @d.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /ds/1
  # DELETE /ds/1.xml
  def destroy
    @d = D.find(params[:id])
    @d.destroy
    
    respond_to do |format|
      format.html { redirect_to(ds_url) }
      format.xml  { head :ok }
    end
  end

  def create_ds_element
    @d = D.find(params[:id])
    ds_element = DsElement.new(params[:ds_element])
    @d.ds_elements << ds_element

    respond_to do |format|
      if @d.save
        format.html { redirect_to(edit_d_path(@d)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @d.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy_ds_element
    @d = D.find(params[:id])
    ds_element_id = params[:ds_element_id]
    @d.ds_elements.each do |ds_element|
      if ds_element.id.to_s ==  ds_element_id
      ds_element.destroy
      end
    end

    respond_to do |format|
      if @d.save
        format.html { redirect_to(edit_d_path(@d)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @d.errors, :status => :unprocessable_entity }
      end
    end
  end

  def manage
    @d = D.find(params[:id])
    #@records = @d.get_klass.all.desc(:position).paginate(:page => params[:page], :per_page => @setting.per_page || 5)

    respond_to do |format|
      #render_html(@d, format)
      format.html { redirect_to :controller => "ds_#{@d.ds_type.pluralize.downcase}", :action => "index", :d => @d.id}
      format.xml  { render :xml => @d }
    end
  end

  private
  
  def current_records(params={})
    current_page = (params[:iDisplayStart].to_i/params[:iDisplayLength].to_i rescue 0)+1

    unless params[:sSearch].blank?
      result = D.any_of(conditions(params))
    else
    result = D.all
    end
    @total_disp_records_size = result.size

    result.desc(:position).paginate :page => current_page,
    #:include => [:user],
    #:order => "#{datatable_columns(params[:iSortCol_0])} #{params[:sSortDir_0] || "DESC"}",
    :per_page => params[:iDisplayLength]
  end
  
  def total_records
    D.all.count
  end

  def conditions(params={})
    cond = []
    sSearch = params[:sSearch]
    Page.fields.each do |field|
      if  field.last.type == "Integer" && sSearch.to_i.to_s == sSearch
        cond << {"#{field.last.name}".to_sym => sSearch.to_i}
      elsif
        cond << {"#{field.last.name}".to_sym => /#{sSearch}/}
      end
    end
    return cond
  end
  
end
