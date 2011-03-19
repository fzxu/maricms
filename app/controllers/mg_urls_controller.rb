class MgUrlsController < ApplicationController
  before_filter :get_setting
  
  # GET /mg_aliases
  # GET /mg_aliases.xml
  def index
    #@mg_aliases = MgAlias.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  #{ render :xml => @mg_aliases }
    end
  end

  def datatable
    @records = current_records(params)
    @total_records = total_records()

    respond_to do |format|
      format.js {render :layout => false}
    end
  end

  # GET /mg_aliases/1
  # GET /mg_aliases/1.xml
  def show
    @mg_url = MgUrl.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @mg_url }
    end
  end

  # GET /mg_aliases/new
  # GET /mg_aliases/new.xml
  def new
    @mg_url = MgUrl.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @mg_url }
    end
  end

  # GET /mg_aliases/1/edit
  def edit
    @mg_url = MgUrl.find(params[:id])
  end

  # POST /mg_aliases
  # POST /mg_aliases.xml
  def create
    @mg_url = MgUrl.new(params[:mg_url])

    respond_to do |format|
      if @mg_url.save
        format.html { redirect_to(mg_urls_path, :notice => 'Mg alias was successfully created.') }
        format.xml  { render :xml => @mg_url, :status => :created, :location => @mg_url }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @mg_url.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /mg_aliases/1
  # PUT /mg_aliases/1.xml
  def update
    @mg_url = MgUrl.find(params[:id])

    respond_to do |format|
      if @mg_url.update_attributes(params[:mg_url])
        format.html { redirect_to(mg_urls_path, :notice => 'Mg alias was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @mg_url.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /mg_aliases/1
  # DELETE /mg_aliases/1.xml
  def destroy
    @mg_url = MgUrl.find(params[:id])
    @mg_url.destroy

    respond_to do |format|
      format.html { redirect_to(mg_urls_url) }
      format.xml  { head :ok }
    end
  end

  private
  
  def current_records(params={})
    current_page = (params[:iDisplayStart].to_i/params[:iDisplayLength].to_i rescue 0)+1

    if params[:sSearch].blank?
      result = MgUrl.all
    else
      result = MgUrl.any_of(conditions(params))
    end
    @total_disp_records_size = result.size

    result.desc(:position).paginate :page => current_page,
    #:include => [:user],
    #:order => "#{datatable_columns(params[:iSortCol_0])} #{params[:sSortDir_0] || "DESC"}",
    :per_page => params[:iDisplayLength]
  end
  
  def total_records
    MgUrl.all.size
  end

  def conditions(params={})
    cond = []
    sSearch = params[:sSearch]
    MgUrl.fields.each do |field|
      if  field.last.type == "Integer" && sSearch.to_i.to_s == sSearch
        cond << {"#{field.last.name}".to_sym => sSearch.to_i}
      elsif
        cond << {"#{field.last.name}".to_sym => /#{sSearch}/}
      end
    end
    return cond
  end

end
