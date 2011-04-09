class DsTreesController < ApplicationController
  before_filter :get_setting
  before_filter :authenticate_user!
  
  # GET /ds_trees
  # GET /ds_trees.xml
  def index
    @d = D.find(params[:d])

    respond_to do |format|
      format.html {render :layout => "ds_view_#{@d.ds_view_type.downcase}" }
      format.xml  { render :xml => @ds_trees }
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

  # GET /ds_trees/1
  # GET /ds_trees/1.xml
  def show
    @d = D.find(params[:d])
    @record = @d.get_klass.find(params[:id])


    respond_to do |format|
      format.html {render :layout => "ds_view_#{@d.ds_view_type.downcase}" }
      format.xml  { render :xml => @record }
    end
  end

  # GET /ds_trees/new
  # GET /ds_trees/new.xml
  def new
    @d = D.find(params[:d])
    @record = @d.get_klass.new

    respond_to do |format|
      format.html {render :layout => "ds_view_#{@d.ds_view_type.downcase}" }
      format.xml  { render :xml => @record }
    end
  end

  # GET /ds_trees/1/edit
  def edit
    @d = D.find(params[:d])
    @record = @d.get_klass.find(params[:id])

    respond_to do |format|
      format.html {render :layout => "ds_view_#{@d.ds_view_type.downcase}" }
      format.xml  { render :xml => @record }
    end    
  end

  # POST /ds_trees
  # POST /ds_trees.xml
  def create
    mg_url = params[:record].delete(:mg_url)
    
    @d = D.find(params[:d])
    parent_id = params[:record].delete(:parent_id)

    @record = @d.get_klass.new(params[:record])

    unless parent_id.blank?
      @record.parent = @d.get_klass.find(parent_id)
    end

    # update the mg url
    unless mg_url[:path].blank?
      @record.mg_url = MgUrl.new(mg_url)
    end

    respond_to do |format|
      if @record.save
        expire_action_cache(@record)
        format.html { redirect_to(ds_trees_path(:d => @d.id), :notice => 'Tree was successfully created.') }
        format.xml  { render :xml => @record, :status => :created, :location => @record }
      else
        format.html { render :action => "new", :layout => "ds_view_#{@d.ds_view_type.downcase}" }
        format.xml  { render :xml => @record.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /ds_trees/1
  # PUT /ds_trees/1.xml
  def update
    mg_url = params[:record].delete(:mg_url)
    
    @d = D.find(params[:d])
    parent_id = params[:record].delete(:parent_id)
    @record = @d.get_klass.find(params[:id])

    unless parent_id.blank?
      @record.parent = @d.get_klass.find(parent_id)
    end

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
    
    #TODO need to remove the existing alias when the passing mg_url is null and @recoard.mg_url has value

    respond_to do |format|
      if @record.update_attributes(params[:record])
        expire_action_cache(@record)
        format.html { redirect_to(ds_trees_path(:d => @d.id), :notice => 'Tree was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit", :layout => "ds_view_#{@d.ds_view_type.downcase}" }
        format.xml  { render :xml => @record.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /ds_trees/1
  # DELETE /ds_trees/1.xml
  def destroy
    @d = D.find(params[:d])
    @record = @d.get_klass.find(params[:id])
    @mg_url = @record.mg_url
    @record.destroy
    if @mg_url
      @mg_url.destroy
    end
    expire_action_cache(@record)
    respond_to do |format|
      format.html { redirect_to(ds_trees_path(:d => @d.id)) }
      format.xml  { head :ok }
    end
  end

  def move_up
    @d = D.find(params[:d])
    @record = @d.get_klass.find(params[:id])
    @record.move_up

    expire_action_cache(@record)
    respond_to do |format|
      format.html {redirect_to(ds_trees_path(:d => @d.id))}
      format.xml  { head :ok }
    end
  end

  def move_down
    @d = D.find(params[:d])
    @record = @d.get_klass.find(params[:id])

    @record.move_down

    expire_action_cache(@record)
    respond_to do |format|
      format.html { redirect_to(ds_trees_path(:d => @d.id))}
      format.xml  { head :ok }
    end
  end
  
  private
  
  def current_records(d, params={})
    result = []

    if params[:sSearch].blank?
      pointer = 0
      counter = 0
      
      d.get_klass.with_scope(d.get_klass.asc(:position)) do
        d.get_klass.traverse(:depth_first) do |rec|
          if pointer >= params[:iDisplayStart].to_i && counter < params[:iDisplayLength].to_i
          result << rec
          counter += 1
          end
          pointer += 1
        end
      end
      @total_disp_records_size = d.get_klass.all.count
      return result
    else
      pointer = 0
      counter = 0
      d.get_klass.with_scope(d.get_klass.asc(:position)) do
        d.get_klass.traverse(:depth_first) do |rec|
          found = false
          rec.fields.each do |field|
            if (rec.send(field.last.name).is_a?(String) && rec.send(field.last.name) =~ /#{params[:sSearch]}/) ||
              ((rec.send(field.last.name).is_a?(Fixnum) || rec.send(field.last.name).is_a?(Float)) && rec.send(field.last.name).to_i.to_s == params[:sSearch])
              found = true
              
            end
          end
          # support parent
          par = rec.parent
          while par
            if  par.mg_name =~ /#{params[:sSearch]}/
              found = true
            end
            par = par.parent
          end  
          if found
            if pointer >= params[:iDisplayStart].to_i && counter < params[:iDisplayLength].to_i
              result << rec
              counter += 1
            end
            pointer += 1
          end
        end
      end
      @total_disp_records_size = pointer
      return result
    end

  end

  def total_records(d)
    d.get_klass.all.size
  end
  
end
