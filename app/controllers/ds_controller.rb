class DsController < ApplicationController
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

    respond_to do |format|
      if @d.update_attributes(params[:d])
        format.html { redirect_to(@d, :notice => 'D was successfully updated.') }
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
end
