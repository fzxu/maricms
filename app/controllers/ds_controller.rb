class DsController < ApplicationController
  before_filter :get_setting

  # GET /ds
  # GET /ds.xml
  def index
    @ds = D.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @ds }
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
      if @d.save && @d.update_attributes(params[:d])
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
    @records = @d.get_klass.all.asc(:position)

    respond_to do |format|
      format.html
      format.xml  { render :xml => @records }
    end
  end

  def edit_record
    @d = D.find(params[:id])
    @record = @d.get_klass.find(params[:rec_id])

    respond_to do |format|
      format.html { render :layout => "edit_record" }
      format.xml  { render :xml => @record }
    end
  end

  def update_record
    @d = D.find(params[:id])
    @record = @d.get_klass.find(params[:rec_id])

    respond_to do |format|
      if @record.update_attributes(params[:record])
        format.html { redirect_to(manage_d_path(@d)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit_record" }
        format.xml  { render :xml => @record.errors, :status => :unprocessable_entity }
      end
    end
  end

  def new_record
    @d = D.find(params[:id])
    @record = @d.get_klass.new

    respond_to do |format|
      format.html { render :layout => "edit_record" }
      format.xml  { render :xml => @record }
    end
  end

  def create_record
    @d = D.find(params[:id])
    @record = @d.get_klass.new(params[:record])

    respond_to do |format|
      if @record.save
        format.html { redirect_to(manage_d_path(@d))}
        format.xml { head :ok}
      else
        format.html { render :action => "new_record"}
        format.xml { render :xml => @record.erros, :status => :unprocessable_entity}
      end
    end
  end

  def destroy_record
    @d = D.find(params[:id])
    @record = @d.get_klass.find(params[:rec_id])
    @record.destroy

    respond_to do |format|
      format.html { redirect_to(manage_d_path(@d)) }
      format.xml  { head :ok }
    end
  end
  
  def show_record
    @d = D.find(params[:id])
    @record = @d.get_klass.find(params[:rec_id])

    respond_to do |format|
      format.html 
      format.xml  { render :xml => @record }
    end
  end
  
  def move_up_record
    @d = D.find(params[:id])
    @record = @d.get_klass.find(params[:rec_id])
    @record.move_up

    respond_to do |format|
      format.html { redirect_to(manage_d_path(@d)) }
      format.xml  { head :ok }
    end    
  end
  
  def move_down_record
    @d = D.find(params[:id])
    @record = @d.get_klass.find(params[:rec_id])
    @record.move_down

    respond_to do |format|
      format.html { redirect_to(manage_d_path(@d)) }
      format.xml  { head :ok }
    end    
  end
end
